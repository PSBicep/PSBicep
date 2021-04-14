function Update-BicepCLI {
    [CmdletBinding()]
    param (
    )

    if (!($IsWindows)) {
        Write-Error -Message "This cmdlet is only supported for Windows systems. `
To update Bicep on your system see instructions on https://github.com/Azure/bicep"
        Write-Host "Compare your Bicep version with latest version by running Get-BicepVersion"
        break
    }

    $versionCheck = CompareBicepVersion

    if ($versionCheck) {
        Write-Host "You are already running the latest version of Bicep CLI."
    }
    elseif ($isWindows) {
        Uninstall-BicepCLI -Force -ErrorAction SilentlyContinue
        Install-BicepCLI -Force
    }
}