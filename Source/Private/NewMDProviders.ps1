function NewMDProviders {
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

    $MDProviders = NewMDTableHeader -Headers 'Type', 'Version'

    $Providers = @()
    foreach ($Resource in $Resources) {
        $Provider = "$($Resource.Type)@$($Resource.apiVersion)"
        if ($Providers -notcontains $Provider) {
            $MDProviders += "| $($Resource.Type) | $($Resource.apiVersion) |`n"
        }
        $Providers += $Provider
    }

    $MDProviders
}