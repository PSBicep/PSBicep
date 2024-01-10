function NewMDResources {
    [CmdletBinding()]
    param(
        [object[]]$Resources
    )

    if (-not $Resources -or $Resources.Count -eq 0) {
        return 'n/a'
    }

    $MDResources = NewMDTableHeader -Headers 'Name', 'Link', 'Location'

    foreach ($Resource in $Resources) {
        try {
            $URI = Get-BicepApiReference -Type "$($Resource.Type)@$($Resource.apiVersion)" -ReturnUri -Force
        }
        catch {
            # If no uri is found this is the base path for template
            $URI = 'https://docs.microsoft.com/en-us/azure/templates'
        }
        $MDResources += "| $($Resource.name) | [$($Resource.Type)@$($Resource.apiVersion)]($URI) | $($Resource.location) |`n"
    }

    $MDResources
}