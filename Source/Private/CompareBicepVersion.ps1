function CompareBicepVersion {
    $installedVersion = InstalledBicepVersion
    $latestVersion = LatestBicepVersion

    if ($installedVersion = $latestVersion) {
        $true
    }
    else {
        $false
    }
}