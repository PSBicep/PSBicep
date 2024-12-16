function Export-BicepResource {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ParameterSetName = 'ByQueryOutPath')]
        [Parameter(Mandatory, ParameterSetName = 'ByQueryOutStream')]
        [string]$KQLQuery,

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
        $Config = Get-BicepConfig -Path $ConfigPath -Merged -AsString | ConvertFrom-Json -AsHashtable
        $CredentialPrecedence = $Config.cloud.credentialPrecedence

        AssertAzureConnection -TokenSplat $script:TokenSplat -CredentialPrecedence $CredentialPrecedence
        
        if ($PSCmdlet.ParameterSetName -like 'ByQuery*') {
            $Resources = SearchAzureResourceGraph -Query $KQLQuery
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
        $ResourceId | Foreach-Object {
            [pscustomobject]@{
                ApiVersion = ((Resolve-BicepResourceType -ResourceId $_) -split '@')[-1]
                ResourceId = $_
            }
        } | Foreach-Object -ThrottleLimit 50 -Parallel {
            
            $ResourceId = $_.ResourceId
            $ApiVersion = $_.ApiVersion
            $hashtable = $using:hash
            
            $maxRetries = 50
            $retryCount = 0
            $backoffInterval = 2
            $TokenThreshold = (Get-Date).AddMinutes(-5)
        
            while ($retryCount -lt $maxRetries) {
        
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
                    $Response = Invoke-WebRequest -Uri $uri -Method 'Get' -Headers $Headers -UseBasicParsing
 
                    if ($Response.StatusCode -eq 200) {
                        $hashtable[$ResourceId] = $Response.Content
                    }
                    else {
                        Write-Warning "Failed to get $_ with status code $($Response.StatusCode)"
                    }
                    return
                }
                catch {
                    # TODO: Implement retry logic for status code 400 with next newest api version
                    # NoRegisteredProviderFound
                    # Exception:
                    # {
                    #   "error": {
                    #     "code": "NoRegisteredProviderFound",
                    #     "message": "No registered resource provider found for location \u0027global\u0027 and API version \u00272023-01-01-preview\u0027 for type \u0027activityLogAlerts\u0027. The supported api-versions are \u00272017-03-01-preview, 2017-04-01, 2020-10-01\u0027. The supported locations are \u0027global, westeurope, northeurope\u0027."
                    #   }
                    # }
                    Write-Warning ("Failed to get resource! {0}" -f $_.Exception.Message)
                    $_
                    if ($_.Exception.Response.StatusCode -eq 429) {
                        if (-not $hashtable['config']['backoff']) {
                            $hashtable['config']['backoff'] = $true
                            Start-Sleep -Seconds ($backoffInterval * [math]::Pow(2, $retryCount))
                            $retryCount++
                            $hashtable['config']['backoff'] = $false
                        }
                    }
                    else {
                        throw $_
                    }
                }
            }
            throw "Max retries reached for $_"
        }
        
    }
    
    end {
        # Ensure that we use any new tokens in module
        $script:Token = $hash['config']['token']
        $hash.Remove('config')
        
        $hash.GetEnumerator() | ForEach-Object {
            $Id = $_.Key
            if ($Raw.IsPresent) {
                $Template = $_.Value
            } else {
                $Template = ConvertTo-Bicep -ResourceId $Id -ResourceBody $_.Value
            }
            if ($PSCmdlet.ParameterSetName -like '*OutPath') {
                $FileName = $Id -replace '/', '_'
                $OutputFilePath = Join-Path -Path $OutputDirectory -ChildPath "$FileName.bicep"
                $null = Out-File -InputObject $Template -FilePath $OutputFilePath -Encoding utf8
            }
            elseif ($PSCmdlet.ParameterSetName -like '*OutStream') {
                if($AsString.IsPresent) {
                    $Template
                }
                else {
                    [pscustomobject]@{
                        ResourceId = $Id
                        Template = $Template
                    }
                }
            }
            else {
                throw [System.NotImplementedException]::new()
            }
        }
    }
}