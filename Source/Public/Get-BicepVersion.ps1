<#
.SYNOPSIS
    View Bicep versions
.DESCRIPTION
    Get-BicepVersion is a command to compare the installed version of Bicep CLI with the latest realease available in the Azure/Bicep repo.
.EXAMPLE
    Get-BicepVersion
    Compare installed version with latest release
.NOTES
    Go to module repository https://github.com/StefanIvemo/BicepPowerShell for detailed info, reporting issues and to submit contributions.
#>
function Get-BicepVersion {
    $installedVersion = InstalledBicepVersion
    $latestVersion = LatestBicepVersion

    [pscustomobject]@{
        InstalledVersion = $installedVersion
        LatestVersion    = $latestVersion
    } 
}