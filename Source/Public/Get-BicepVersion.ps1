function Get-BicepVersion {
    $installedVersion = InstalledBicepVersion
    $latestVersion = LatestBicepVersion

    [pscustomobject]@{
        InstalledVersion = $installedVersion
        LatestVersion    = $latestVersion
    } 
}