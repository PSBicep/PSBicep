function SearchAzureResourceGraph {
    [CmdletBinding(DefaultParameterSetName = 'String')]
    param(
        # Path to the KQL query file
        [Parameter(Mandatory, ParameterSetName = 'Path')]
        [ValidateNotNullOrEmpty()]
        [string]$QueryPath,
    
        # KQL query string
        [Parameter(Mandatory, ParameterSetName = 'String')]
        [ValidateNotNullOrEmpty()]
        [string]$Query,

        # Subscription IDs to run the query against
        [Parameter(ParameterSetName = 'Path')]
        [Parameter(ParameterSetName = 'String')]
        [string[]]$SubscriptionId,
        
        # Management Groups to run the query againstß
        [Parameter(ParameterSetName = 'Path')]
        [Parameter(ParameterSetName = 'String')]
        [string[]]$ManagementGroup,

        # Scope filter for the authorization
        [Parameter(ParameterSetName = 'Path')]
        [Parameter(ParameterSetName = 'String')]
        [ValidateSet('AtScopeAboveAndBelow', 'AtScopeAndAbove', 'AtScopeAndBelow', 'AtScopeExact')]
        [string]$AuthorizationScopeFilter = 'AtScopeAndBelow',

        # Allow partial scopes in the query
        [Parameter(ParameterSetName = 'Path')]
        [Parameter(ParameterSetName = 'String')]
        [bool]$AllowPartialScopes = $false,

        # PageSize for the query
        [Parameter(ParameterSetName = 'Path')]
        [Parameter(ParameterSetName = 'String')]
        [ValidateRange(1, 1000)]
        [int]$PageSize = 1000
    )

    # Ensure only one of SubscriptionId or ManagementGroup is provided
    if ($PSBoundParameters.ContainsKey('SubscriptionId') -and $PSBoundParameters.ContainsKey('ManagementGroup')) {
        throw 'KQL Query can only be run against either a Subscription or a Management Group, not both.'
    }
    
    AssertAzureConnection -TokenSplat $script:TokenSplat

    if ($PSCmdlet.ParameterSetName -eq 'Path') {
        $Query = Get-Content $QueryPath -Raw
    }

    $Uri = 'https://management.azure.com/providers/Microsoft.ResourceGraph/resources?api-version=2022-10-01'
    $Body = @{
        query   = $Query
        options = @{
            resultFormat             = 'objectArray'
            authorizationScopeFilter = $AuthorizationScopeFilter
            allowPartialScopes       = $AllowPartialScopes
            '$top'                   = $PageSize
            '$skip'                  = 0
        }
    }

    if ($PSBoundParameters.ContainsKey('SubscriptionId')) { $Body['subscriptions'] = @($SubscriptionId) }
    if ($PSBoundParameters.ContainsKey('ManagementGroup')) { $Body['managementGroups'] = @($ManagementGroup) } 

    $Headers = @{
        'Authorization' = "Bearer $($script:Token.Token)"
        'Content-Type'  = 'application/json'
    }

    $PageParams = @{
        Uri = $Uri
        Body = $Body
        Headers = $Headers
        TotalRecords = 0
        ResultHeaders = @{}
        Output = [System.Collections.ArrayList]::new()
    }

    while ($PageParams['TotalRecords'] -eq 0 -or $PageParams['TotalRecords'] -gt $PageParams['Body']['options']['$skip']) {
        $PageParams = GetAzResourceGraphPage @PageParams
        if($PageParams.Output.Count -gt 0) { 
            Write-Verbose "Outputting $($PageParams.Output.Count) records."
            Write-Output $PageParams.Output
            $PageParams.Output.Clear()
        }
    }
}

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