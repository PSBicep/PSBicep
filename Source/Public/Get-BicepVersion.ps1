function Get-BicepVersion {
    param (
        [switch]$All

    )
    if ($All.IsPresent) {
        ListBicepVersions
    }
    else {
        $installedVersion = InstalledBicepVersion
        $latestVersion = ListBicepVersions -Latest
    
        [pscustomobject]@{
            InstalledVersion = $installedVersion
            LatestVersion    = $latestVersion
        } 
    }
}