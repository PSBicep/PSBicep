function Get-BicepVersion {
    param (
        [switch]$All

    )
    if (-not $Script:ModuleVersionChecked) {
        TestModuleVersion
    }
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