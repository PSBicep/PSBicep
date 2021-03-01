function ListBicepVersions {
    [CmdletBinding()]
    param (
        [switch]$Latest

    )

    $BaseURL = 'https://api.github.com/repos/Azure/bicep/releases'
    
    if ($Latest) {
        $LatestVersion = Invoke-RestMethod -Uri ('{0}/latest' -f $BaseURL)
        $LatestVersion.tag_name
    }
    else {
        $AvailableVersions = Invoke-RestMethod -Uri $BaseURL
        $AvailableVersions.tag_name
    }    

}