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
        [switch]$IncludeTargetScope
    )
    
    begin {
        AssertAzureConnection -TokenSplat $script:TokenSplat
        
        if ($PSCmdlet.ParameterSetName -like 'ByQuery*') {
            $Resources = SearchAzureResourceGraph -QueryPath $KQLQuery
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
        $script:Token = $hashtable['config']['token']
    }
}
