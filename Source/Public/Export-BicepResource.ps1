function Export-BicepResource {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ParameterSetName = 'ByQueryOutPath')]
        [Parameter(Mandatory, ParameterSetName = 'ByQueryOutStream')]
        [string]$KQLQuery,
        
        [Parameter(ParameterSetName = 'ByQueryOutPath')]
        [Parameter(ParameterSetName = 'ByQueryOutStream')]
        [switch]$UseKQLResult,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'ByIdOutPath')]
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'ByIdOutStream')]
        [Alias('id')]
        [string[]]$ResourceId,
        
        [Parameter(Mandatory, ParameterSetName = 'ByQueryOutPath')]
        [Parameter(Mandatory, ParameterSetName = 'ByIdOutPath')]
        [string]$OutputDirectory,
        
        [Parameter(ParameterSetName = 'ByQueryOutPath')]
        [Parameter(ParameterSetName = 'ByQueryOutStream')]
        [Parameter(ParameterSetName = 'ByIdOutPath')]
        [Parameter(ParameterSetName = 'ByIdOutStream')]
        [switch]$IncludeTargetScope,

        [Parameter(ParameterSetName = 'ByQueryOutPath')]
        [Parameter(ParameterSetName = 'ByQueryOutStream')]
        [Parameter(ParameterSetName = 'ByIdOutPath')]
        [Parameter(ParameterSetName = 'ByIdOutStream')]
        [switch]$RemoveUnknownProperties,
        
        [Parameter(ParameterSetName = 'ByQueryOutStream')]
        [Parameter(ParameterSetName = 'ByIdOutStream')]
        [switch]$AsString,

        [Parameter(ParameterSetName = 'ByQueryOutPath')]
        [Parameter(ParameterSetName = 'ByQueryOutStream')]
        [Parameter(ParameterSetName = 'ByIdOutPath')]
        [Parameter(ParameterSetName = 'ByIdOutStream')]
        [switch]$Raw
    )
    
    begin {
        # Get bicepconfig based on current location
        $ConfigPath = Get-Location
        $Config = Get-BicepConfig -Path $ConfigPath -Merged

        AssertAzureConnection -TokenSplat $script:TokenSplat -BicepConfig $Config
        
        if ($PSCmdlet.ParameterSetName -like 'ByQuery*') {
            $Resources = Search-AzResourceGraph -Query $KQLQuery -Token $script:Token
            if ($null -eq $Resources.id) {
                throw 'KQL query must return a column named "id"'
            }
            $ResourceId = @($Resources.id)
        }
        
        $hash = [hashtable]::Synchronized(@{})
        $hash['config'] = @{}
        $hash['config']['backoff'] = $false
        $hash['config']['token'] = $script:Token
        $hash['config']['tokensplat'] = $script:TokenSplat
        $AssertFunction = Get-Item "function:\AssertAzureConnection"
    }
    
    process {
        if ($UseKQLResult.IsPresent) {
            Write-Warning 'Using KQL result from Azure Resource Graph is experimental and may generate invalid or incomplete bicep files'
            foreach ($resource in $Resources) {
                $hash[$resource.id] = $resource | ConvertTo-Json -Depth 100
            }
        } else {
            $ResourceId | Foreach-Object {
                try{
                    $resolvedType = Resolve-BicepResourceType -ResourceId $_ -ErrorAction 'Stop'

                } catch {
                    Write-Warning "Failed to resolve resource type for $_, skipping."
                    return
                }
                [pscustomobject]@{
                    ApiVersions = Get-BicepApiVersion -ResourceType $resolvedType
                    ResourceId = $_
                    TypeIndex = 0
                }
            } | Foreach-Object -ThrottleLimit 50 -Parallel {
                
                $ResourceId = $_.ResourceId
                $ApiVersionList = $_.ApiVersions
                $TypeIndex = $_.TypeIndex
                $hashtable = $using:hash
                
                $maxRetries = 50
                $retryCount = 0
                $backoffInterval = 2
                $TokenThreshold = (Get-Date).AddMinutes(-5)
            
                while ($retryCount -lt $maxRetries) {
                    $ApiVersion = $ApiVersionList[$TypeIndex]
                    while ($hashtable['config']['backoff']) {
                        Write-Warning "$ResourceId is backing off"
                        Start-Sleep -Seconds 10
                    }
    
                    $hashtable['config']['token'] = $using:Token
                    if (-not $hashtable['config']['backoff'] -and $hashtable['config']['token'].ExpiresOn -lt $TokenThreshold) {
                        $hashtable['config']['backoff'] = $true
                        & $using:AssertFunction -TokenSplat $hash['config']['TokenSplat']
                        $hashtable['config']['token'] = $script:Token
                        $hashtable['config']['backoff'] = $false
                    }
                 
                    try {
                        $uri = "https://management.azure.com/${ResourceId}?api-version=$ApiVersion"
                        $Headers = @{
                            authorization = "Bearer $($hashtable['config']['token'].Token)"
                            contentType   = 'application/json'
                        }
                        $Response = Invoke-WebRequest -Uri $uri -Method 'Get' -Headers $Headers -UseBasicParsing -ErrorAction 'Stop'
     
                        if ($Response.StatusCode -eq 200) {
                            $hashtable[$ResourceId] = $Response.Content
                        }
                        else {
                            Write-Warning "Failed to get $_ with status code $($Response.StatusCode)"
                        }
                        return
                    }
                    catch {
                        $CurrentError = $_

                        # Retrylogic for 400 errors
                        if ($CurrentError.Exception.Response.StatusCode -eq 400) {

                            # If error is due to no registered provider or invalid ApiVersion, try next api version
                            if(
                                $CurrentError.ErrorDetails.Message -like '*"code": "NoRegisteredProviderFound"*' -or
                                $CurrentError.ErrorDetails.Message -like '*"code": "InvalidApiVersionParameter"*'
                            ) {
                                $TypeIndex++
                                $retryCount++
                                if ($TypeIndex -ge $ApiVersionList.Count) {
                                    Write-Warning "No more api versions to try for $ResourceId"
                                    Write-Warning $CurrentError
                                }
                                continue
                            }
                        }

                        if ($CurrentError.Exception.Response.StatusCode -eq 429) {
                            if (-not $hashtable['config']['backoff']) {
                                $hashtable['config']['backoff'] = $true
                                Start-Sleep -Seconds ($backoffInterval * [math]::Pow(2, $retryCount))
                                $retryCount++
                                $hashtable['config']['backoff'] = $false
                            }
                        }

                        Write-Warning ("Failed to get resource! {0}" -f $CurrentError.Exception.Message)
                        Write-Warning $CurrentError
                    }
                }
                Write-Warning "Max retries reached for $_"
            }
        }
        
    }
    
    end {
        # Ensure that we use any new tokens in module
        $script:Token = $hash['config']['token']
        $hash.Remove('config')
        if (-not $Raw.IsPresent) {
            $convertParams = @{
                ResourceDictionary      = $hash
                RemoveUnknownProperties = $RemoveUnknownProperties.IsPresent
                IncludeTargetScope      = $IncludeTargetScope.IsPresent
                ErrorAction             = 'Stop'
            }
            $hash = ConvertTo-Bicep @convertParams
        }
        $hash.GetEnumerator() | ForEach-Object {
            $Id = $_.Key
            $Template = $_.Value

            if ($PSCmdlet.ParameterSetName -like '*OutPath') {
                if (-not (Test-Path -Path $OutputDirectory -PathType 'Container')) {
                    $null = New-Item -Path $OutputDirectory -ItemType 'Directory'
                }
                $ResourceIdParts = $Id -split '/'
                $FileName = [string]::Concat($ResourceIdParts[6], '_', $ResourceIdParts[7], '-', $ResourceIdParts[8])
                $OutputFilePath = Join-Path -Path $OutputDirectory -ChildPath "$FileName.bicep"
                $null = Out-File -InputObject $Template -FilePath $OutputFilePath -Encoding utf8
            }
            elseif ($PSCmdlet.ParameterSetName -like '*OutStream') {
                if ($AsString.IsPresent) {
                    $Template
                }
                else {
                    [pscustomobject]@{
                        ResourceId = $Id
                        Template   = $Template
                    }
                }
            }
            else {
                throw [System.NotImplementedException]::new()
            }
        }
    }
}