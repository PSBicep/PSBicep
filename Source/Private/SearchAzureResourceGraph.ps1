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
    # $ResultCount = 0
    # $Result = Invoke-WebRequest -Uri $Uri -Method 'POST' -Body ($Body | ConvertTo-Json -Compress) -Headers $Headers
    # $ResultData = $Result.Content | ConvertFrom-Json -Depth 100
    # $TotalRecords = $ResultData.totalRecords
    # $ResultCount += $ResultData.data.Count

    # Add skipToken to body to get next page of same result
    # $Body['options']['$skipToken'] = $ResultData.'$skipToken'

    # Output the first page of results
    # Write-Output $ResultData.data

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
        if($PageParams.Output.Clount -gt 0) { 
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
    if($ResultHeaders.ContainsKey('x-ms-user-quota-remaining') -and $ResultHeaders['x-ms-user-quota-remaining'] -lt 1) {
        # Hit the quota limit, wait before retrying
        Wait-Debugger
        $QuotaResetAfter = $ResultHeaders['x-ms-user-quota-resets-after']
        $SleepTime = [TimeSpan]$QuotaResetAfter
        Write-Warning "Quota limit reached. Waiting $($SleepTime.TotalMilliseconds) milliseconds before retrying."
        Start-Sleep -Milliseconds $SleepTime.TotalMilliseconds
    }

    # Check if we are at the end of the records
    if ($TotalRecords -gt 0 -and $PSBoundParameters['Body']['options']['$top'] -gt ($TotalRecords - $PSBoundParameters['Body']['options']['$skip'])) {
        $PSBoundParameters['Body']['options']['$top'] = $TotalRecords - $PSBoundParameters['Body']['options']['$skip']
    }

    # Check if there are any more records to retrieve
    if($Body['options']['$top'] -lt 1) {
        Write-Verbose "No more records to retrieve."
        return $PSBoundParameters
    }
    
    Write-Verbose "Retrieving next page of $($PSBoundParameters['Body']['options']['$top']) items."
    
    try {
        $Result = Invoke-WebRequest -Uri $Uri -Method 'POST' -Body ($PSBoundParameters['Body'] | ConvertTo-Json -Compress) -Headers $Headers -ErrorAction 'Stop'
        $ResultData = $Result.Content | ConvertFrom-Json -Depth 100
        $PSBoundParameters['Output'].AddRange($ResultData.data)
        $PSBoundParameters['TotalRecords'] = $ResultData.totalRecords
        $PSBoundParameters['Body']['options']['$skip'] += $ResultData.data.Count
        Write-Verbose "Successfully retrieved $($PSBoundParameters['Body']['options']['$skip']) of $($PSBoundParameters['TotalRecords']) records. Next batch sice: $($Body['options']['$top'])."
    }
    catch {
        try {
            # If the error is due to payload size, reduce the batch size and call recursively
            $ErrorDetails = $_.ErrorDetails.Message | ConvertFrom-Json -ErrorAction 'Stop'
            if ($ErrorDetails.error.details.code -eq 'ResponsePayloadTooLarge') { # There is a payload size limit of 16777216 bytes
                if($ErrorDetails.error.details.message -match 'Response payload size is (?<ResponseSize>\d+), and has exceeded the limit of (?<Limit>\d+). Please consider querying less data at a time and make paginated call if needed.') {
                    # Estimate new batch size based on the response size ratio to limit, add 1 to be on the safe side.
                    $OriginalBatchSize = $PSBoundParameters['Body']['options']['$top']
                    $ReductionRatio = [Math]::Ceiling($Matches['ResponseSize'] / $Matches['Limit']) + 1
                    [int]$NewBatchSize = $PSBoundParameters['Body']['options']['$top'] / $ReductionRatio
                    $PSBoundParameters['Body']['options']['$top'] = $NewBatchSize
                    Write-Verbose "====================="
                    Write-Verbose "Response payload too large ($($Matches['ResponseSize'])). Retrying with smaller batch size: $($PSBoundParameters['Body']['options']['$top'])."
                    for ($i = 0; $i -lt $ReductionRatio; $i++) {
                        $PSBoundParameters = GetAzResourceGraphPage @PSBoundParameters
                    }
                    Write-Verbose "Resetting batch size to original value: $OriginalBatchSize."
                    $PSBoundParameters['Body']['options']['$top'] = $OriginalBatchSize
                    Write-Verbose "---------------------"
                }
            }
        }
        catch {
            Write-Error "Failed to parse error details: $_" -TargetObject $ErrorDetails
        }
    }
    return $PSBoundParameters
}

# $null = {
#     # Check if we hit the quota limit
#     if ($Result.Headers['x-ms-user-quota-remaining'][0] -lt 1) {
#         # Hit the quota limit, wait before retrying
#         $SleepTime = [TimeSpan]$Result.Headers['x-ms-user-quota-resets-after'][0]
#         Write-Warning "Quota limit reached. Waiting $($SleepTime.TotalMilliseconds) milliseconds before retrying."
#         Start-Sleep -Milliseconds $SleepTime.TotalMilliseconds
#     }

#     # Check if we are at the end of the records
#     if ($Body['options']['$top'] -gt ($TotalRecords - $ResultCount)) {
#         $Body['options']['$top'] = $TotalRecords - $ResultCount
#     }

#     # Add skipToken to body to get next page of same result
#     $Body['options']['$skipToken'] = $ResultData.'$skipToken'
#     $Body['options']['$skip'] = $ResultCount
#     try {
#         $Result = Invoke-WebRequest -Uri $Uri -Method 'POST' -Body ($Body | ConvertTo-Json -Compress) -Headers $Headers -ErrorAction 'Stop'
#     }
#     catch {
#         try {
#             # If the error is due to payload size, reduce the batch size and call recursively
#             $ErrorDetails = $_.ErrorDetails.Message | ConvertFrom-Json -ErrorAction 'Stop'
#             if ($ErrorDetails.error.details.code -eq 'ResponsePayloadTooLarge') { # There is a payload size limit of 16777216 bytes
#                 if($ErrorDetails.error.details.message -match 'Response payload size is (?<ResponseSize>\d+), and has exceeded the limit of (?<Limit>\d+). Please consider querying less data at a time and make paginated call if needed.') {
#                     # Estimate new batch size based on the response size ratio to limit, add 1 to be on the safe side.
#                     $ReductionRatio = [Math]::Ceiling($Matches['ResponseSize'] / $Matches['Limit']) + 1
#                     [int]$NewBatchSize = $Body['options']['$top'] / $ReductionRatio
#                     for ($i = 0; $i -lt $ReductionRatio; $i++) {
#                         SearchAzureResourceGraph @PSBoundParameters -PageSize $NewBatchSize
#                         <# Action that will repeat until the condition is met #>
#                     }
                    
#                     $Body['options']['$top'] = [int]($Body['options']['$top'] / [Math]::Ceiling($Matches['ResponseSize'] / $Matches['Limit']))
#                     Write-Verbose "Response payload too large ($($Matches['ResponseSize'])). Retrying with smaller batch size: $($Body['options']['$top'])."
#                     continue
#                 }
#             }
#         }
#         catch {
#             Write-Error "Failed to parse error details: $_" -TargetObject $ErrorDetails
#         }
#         throw
#     }
#     $ResultData = $Result.Content | ConvertFrom-Json -Depth 100
#     Write-Output $ResultData.data
#     $ResultCount += $ResultData.data.Count
#     Write-Verbose "Successfully retrieved $ResultCount of $TotalRecords records. Next batchg sice: $($Body['options']['$top'])."
# }