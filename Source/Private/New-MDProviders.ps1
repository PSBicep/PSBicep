function New-MDProviders {
    [CmdletBinding()]
    param(
        [object[]]$Providers
    )

    if (-not $Providers -or $Providers.Count -eq 0) {
        return 'n/a'
    }

    $MDProviders = New-MDTableHeader -Headers 'Type', 'Version'

    foreach ($provider in $Providers) {
        $MDProviders += "| $($Provider.Type) | $($Provider.apiVersion) |`n"
    }

    $MDProviders
}