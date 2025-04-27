function GetAzResourceGraphPage {
    [CmdletBinding()]
    param (
        [string]$Uri,
        [hashtable]$Body,
        [hashtable]$Headers,
        [int]$TotalRecords,
        [System.Collections.ArrayList]$Output,
        [hashtable]$ResultHeaders
    )

    # Check if we hit the quota limit
    if($ResultHeaders.ContainsKey('x-ms-user-quota-remaining') -and $ResultHeaders['x-ms-user-quota-remaining'][0] -lt 1) {
        # Hit the quota limit, wait before retrying
        $QuotaResetAfter = $ResultHeaders['x-ms-user-quota-resets-after'] | Select-Object -First 1
        $SleepTime = [TimeSpan]$QuotaResetAfter
        Write-Warning "Quota limit reached. Waiting $($SleepTime.TotalMilliseconds) milliseconds before retrying."
        Start-Sleep -Milliseconds $SleepTime.TotalMilliseconds
    }

    # Check if we are at the end of the records
    if ($TotalRecords -gt 0 -and $Body['options']['$top'] -gt ($TotalRecords - $Body['options']['$skip'])) {
        $Body['options']['$top'] = $TotalRecords - $Body['options']['$skip']
    }

    # Check if there are any more records to retrieve
    if($Body['options']['$top'] -gt 0) {
        Write-Verbose "Retrieving next page of $($Body['options']['$top']) items."
        
        try {

            $Result = Invoke-WebRequest -Uri $Uri -Method 'POST' -Body ($Body | ConvertTo-Json -Compress) -Headers $Headers -ErrorAction 'Stop'
            $ResultData = $Result.Content | ConvertFrom-Json -Depth 100
            $Output.AddRange($ResultData.data)
            $TotalRecords = $ResultData.totalRecords
            $Body['options']['$skip'] += $ResultData.data.Count
            Write-Verbose "Successfully retrieved $($Body['options']['$skip']) of $TotalRecords records. Next batch sice: $($Body['options']['$top'])."
            $PageParams = @{
                Uri = $Uri
                Body = $Body
                Headers = $Headers
                TotalRecords = $TotalRecords
                ResultHeaders = $Result.Headers
                Output = $Output
            }
        }
        catch {
            try {
                # If the error is due to payload size, reduce the batch size and call recursively
                $ErrorDetails = $_.ErrorDetails.Message | ConvertFrom-Json -ErrorAction 'Stop'
                if ($ErrorDetails.error.details.code -eq 'ResponsePayloadTooLarge') { # There is a payload size limit of 16777216 bytes
                    if($ErrorDetails.error.details.message -match 'Response payload size is (?<ResponseSize>\d+), and has exceeded the limit of (?<Limit>\d+). Please consider querying less data at a time and make paginated call if needed.') {
                        # Estimate new batch size based on the response size ratio to limit, add 1 to be on the safe side.
                        $OriginalBatchSize = $Body['options']['$top']
                        $ReductionRatio = [Math]::Ceiling($Matches['ResponseSize'] / $Matches['Limit']) + 1
                        [int]$NewBatchSize = $Body['options']['$top'] / $ReductionRatio
                        $Body['options']['$top'] = $NewBatchSize
                        Write-Verbose "Response payload too large ($($Matches['ResponseSize'])). Retrying with smaller batch size: $($Body['options']['$top'])."
                        for ($i = 0; $i -lt $ReductionRatio; $i++) {
                            $PageParams['Body'] = $Body
                            $PageParams = GetAzResourceGraphPage @PageParams
                        }
                        Write-Verbose "Resetting batch size to original value: $OriginalBatchSize."
                        $PageParams['Body']['options']['$top'] = $OriginalBatchSize
                    }
                }
            }
            catch {
                Write-Error "Failed to parse error details: $_" -TargetObject $ErrorDetails -ErrorAction 'Stop'
            }
        }
    }
    
    return $PageParams
}