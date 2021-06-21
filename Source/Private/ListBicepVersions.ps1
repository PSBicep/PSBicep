function ListBicepVersions {
    [CmdletBinding()]
    param (
        [switch]$Latest

    )
    $BaseURL = 'https://api.github.com/repos/Azure/bicep/releases'
    
    if ($Latest) {
        try {
            $LatestVersion = Invoke-RestMethod -Uri ('{0}/latest' -f $BaseURL)
            $LatestVersion.tag_name -replace '[v]', ''
        }
        catch {
            Write-Error -Message "Could not get latest version from GitHub. $_" -Category ObjectNotFound
        }
    }
    else {
        try {
            $AvailableVersions = Invoke-RestMethod -Uri $BaseURL
            $AvailableVersions.tag_name -replace '[v]', ''   
        }
        catch {
            Write-Error -Message "Could not get versions from GitHub. $_" -Category ObjectNotFound
        }
    }
}