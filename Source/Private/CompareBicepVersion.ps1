function CompareBicepVersion {
    $installedVersion = InstalledBicepVersion
    $latestVersion = ListBicepVersions -Latest

    if ($installedVersion -eq $latestVersion) {
        $true
    }
    else {
        $false
    }
}
