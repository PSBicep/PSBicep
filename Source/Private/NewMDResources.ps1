function NewMDResources {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [AllowNull()]
        [object[]]$Resources,

        [Parameter()]
        [string]$LanguageVersion = '1.0'
    )

    if (-not $Resources -or $Resources.Count -eq 0) {
        return 'n/a'
    }

    $MDResources = NewMDTableHeader -Headers 'Name', 'Link', 'Location'
    
    # If language version is 2.0, $Resources is a dictionary and we need to adapt the object
    if ($LanguageVersion -eq '2.0') {
        $Resources = foreach ($ResourceName in $Resources[0].psobject.properties.name) {
            $Resource = $Resources."$ResourceName"
            $Hash = @{}
            foreach ($PropertyName in $Resource.psobject.properties.name) {
                $Hash[$PropertyName] = $Resource."$PropertyName"
            }
            [pscustomobject]$Hash
        }
    }

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