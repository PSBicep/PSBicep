function NewMDProviders {
    [CmdletBinding()]
    param(
        [object[]]$Providers
    )

    if (-not $Providers -or $Providers.Count -eq 0) {
        return 'n/a'
    }

    $MDProviders = NewMDTableHeader -Headers 'Type', 'Version'

    foreach ($provider in $Providers) {
        $MDProviders += "| $($Provider.Type) | $($Provider.apiVersion) |`n"
    }

    $MDProviders
}