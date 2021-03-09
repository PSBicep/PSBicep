function LatestBicepVersion {
    [CmdletBinding()]
    param ()

    try {
        $latestVersion = Invoke-RestMethod -URI "https://api.github.com/repos/Azure/Bicep/releases/latest" -ErrorAction Stop
        $latestVersion.tag_name -replace '[v]', ''
    }
    catch {
        Write-Error -Message "Could not get latest version from GitHub. $_" -Category ObjectNotFound
    }
}