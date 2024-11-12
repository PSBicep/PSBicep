function SearchAzureResourceGraph {
    [CmdletBinding(DefaultParameterSetName = 'String')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'Path')]
        [ValidateNotNullOrEmpty()]
        [string]$QueryPath,
    
        [Parameter(Mandatory, ParameterSetName = 'String')]
        [ValidateNotNullOrEmpty()]
        [string]$Query,

        [Parameter(ParameterSetName = 'Path')]
        [Parameter(ParameterSetName = 'String')]
        [string[]]$SubscriptionId,
        
        [Parameter(ParameterSetName = 'Path')]
        [Parameter(ParameterSetName = 'String')]
        [string[]]$ManagementGroup,

        [ValidateSet('AtScopeAboveAndBelow', 'AtScopeAndAbove', 'AtScopeAndBelow', 'AtScopeExact')]
        [string]$AuthorizationScopeFilter = 'AtScopeAndBelow',

        [bool]$AllowPartialScopes = $false
    )

    if ($PSBoundParameters.ContainsKey('SubscriptionId') -and $PSBoundParameters.ContainsKey('ManagementGroup')) {
        throw 'KQL Query can only be run against either a Subscription or a Management Group, not both.'
    }
    
    AssertAzureConnection

    if ($PSCmdlet.ParameterSetName -eq 'Path') {
        $Query = Get-Content $QueryPath -Raw
    }

    $Uri = 'https://management.azure.com/providers/Microsoft.ResourceGraph/resources?api-version=2022-10-01'
    $Body = @{
        query = $Query
        options = @{
            resultFormat = 'objectArray'
            authorizationScopeFilter = $AuthorizationScopeFilter
            allowPartialScopes = $AllowPartialScopes
            '$top' = 1000 # BatchSize
            '$skip' = 0
        }
    }

    if ($PSBoundParameters.ContainsKey('SubscriptionId')) { $Body['subscriptions'] = @($SubscriptionId) }
    if ($PSBoundParameters.ContainsKey('ManagementGroup')) { $Body['managementGroups'] = @($ManagementGroup) } 

    $Headers = @{
        'Authorization' = "Bearer $($script:Token.Token)"
        'Content-Type'  = 'application/json'
    }

    $Result = $null
    while ($null -eq $Result -or $Body['options']['$skip'] -lt $Result.totalRecords) {
        $Result = Invoke-RestMethod -Uri $Uri -Method 'POST' -Body ($Body | ConvertTo-Json -Compress) -Headers $Headers

        Write-Output $Result.data
        
        $Body['options']['$skip'] += $Result.count
    }
}
