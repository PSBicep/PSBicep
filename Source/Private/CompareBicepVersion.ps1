function CompareBicepVersion {
    $installedVersion = InstalledBicepVersion
    $latestVersion = LatestBicepVersion

    if ($installedVersion -eq $latestVersion) {
        $true
    }
    else {
        $false
    }
}
