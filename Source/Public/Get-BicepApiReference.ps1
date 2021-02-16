function Get-BicepApiReference {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, 
                   Position = 0)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ 
                ($Global:BicepResourceProviders).ResourceProvider -contains $_ 
            }, 
                ErrorMessage = "ResourceProvider '{0}' was not found.")]
        [ArgumentCompleter({
            param ( $commandName,
                    $parameterName,
                    $wordToComplete,
                    $commandAst,
                    $BoundParameters )
            ($Global:BicepResourceProviders).ResourceProvider | Where-Object { $_ -like "$wordToComplete*" } | Sort-Object
        })]
        [string]$ResourceProvider,

        [Parameter(Mandatory, 
                   Position = 1)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ 
                ($Global:BicepResourceProviders).Resource -contains $_ 
            }, 
                ErrorMessage = "Resource '{0}' was not found.")]
        [ArgumentCompleter({
            param ( $commandName,
                    $parameterName,
                    $wordToComplete,
                    $commandAst,
                    $BoundParameters )
            if ($BoundParameters.ContainsKey('ResourceProvider'))
            {
                ($Global:BicepResourceProviders) | Where-Object {
                    $_.ResourceProvider -eq $BoundParameters.ResourceProvider -and $_.Resource -like "$wordToComplete*"
                } | Select-Object -ExpandProperty Resource | Sort-Object
            }
            else
            {
                ($Global:BicepResourceProviders).Resource | Select-Object -Unique | Sort-Object
            }
        })]
        [string]$Resource,
        
        [Parameter(Position = 2)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ 
            ($Global:BicepResourceProviders).ApiVersion -contains $_ 
        }, 
            ErrorMessage = "ApiVersion '{0}' was not found.")]
        [ArgumentCompleter({
            param ( $commandName,
                    $parameterName,
                    $wordToComplete,
                    $commandAst,
                    $BoundParameters )
            if ($BoundParameters.ContainsKey('ResourceProvider') -and $BoundParameters.ContainsKey('Resource'))
            {
                ($Global:BicepResourceProviders) | Where-Object {
                    $_.ResourceProvider -eq $BoundParameters.ResourceProvider -and $_.Resource -eq $BoundParameters.Resource -and $BoundParameters.ApiVersion -like "$wordToComplete*"
                } | Select-Object -ExpandProperty ApiVersion | Sort-Object
            }
            else
            {
                ($Global:BicepResourceProviders).Resource | Select-Object -Unique | Sort-Object
            }
        })]
        [string]$ApiVersion
    )

    $baseUrl = "https://docs.microsoft.com/en-us/azure/templates"

    if ($ApiVersion) {
        #Get specified API Verion
        $url = "$BaseUrl/$ResourceProvider/$ApiVersion/$Resource"
    }
    else {
        #Get latest API Version
        $url = "$BaseUrl/$ResourceProvider/$Resource"
    }
    
    try {
        $null = Invoke-WebRequest -Uri $url -ErrorAction Stop
        $DocsFound = $true
    }
    catch {
        $DocsFound = $false
    }

    if ($DocsFound) {
        Start-Process $url
    }
    else {
        Write-Error "No documentation found at $url"        
    }

}

