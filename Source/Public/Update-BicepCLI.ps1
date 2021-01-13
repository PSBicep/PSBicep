<#
.SYNOPSIS
    Update Bicep CLI
.DESCRIPTION
    Update-BicepCLI is a command to update to the latest Bicep CLI realease available from the Azure/Bicep repo.
.EXAMPLE
    Update-BicepCLI
    Update Bicep CLI
.NOTES
    Go to module repository https://github.com/StefanIvemo/BicepPowerShell for detailed info, reporting issues and to submit contributions.
#>
function Update-BicepCLI {
    $versionCheck = CompareBicepVersion

    if ($versionCheck) {
        Write-Host "You are already running the latest version of Bicep CLI."
    }
    else {
        Install-BicepCLI -Force
    }     
}