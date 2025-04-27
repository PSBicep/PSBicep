function Search-AzureResourceGraph {
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

        # Allow partial scopes in the query. Only applicable for tenant and management group level queries to decide whether to allow partial scopes for result in case the number of subscriptions exceed allowed limits.
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

