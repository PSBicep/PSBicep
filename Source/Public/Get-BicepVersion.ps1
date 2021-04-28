function Get-BicepVersion {
    [CmdletBinding(HelpUri = 'https://github.com/StefanIvemo/BicepPowerShell/blob/v1.4.5/Docs/Help/Get-BicepVersion.md')]
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
