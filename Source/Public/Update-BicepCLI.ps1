function Update-BicepCLI {
    [CmdletBinding()]
    param (
    )
    
    $versionCheck = CompareBicepVersion

    if ($versionCheck) {
        Write-Host "You are already running the latest version of Bicep CLI."
    }
    else {
        Uninstall-BicepCLI -Force
        Install-BicepCLI -Force
    }     
}