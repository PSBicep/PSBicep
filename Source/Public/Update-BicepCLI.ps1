function Update-BicepCLI {
    [CmdletBinding(HelpUri = 'https://github.com/StefanIvemo/BicepPowerShell/blob/v1.4.5/Docs/Help/Update-BicepCLI.md')]
    param (
    )

    if (!($IsWindows)) {
        Write-Error -Message "This cmdlet is only supported for Windows systems. `
To update Bicep on your system see instructions on https://github.com/Azure/bicep"
        Write-Host "`nCompare your Bicep version with latest version by running Get-BicepVersion`n"
        break
    }

    $versionCheck = CompareBicepVersion

    if ($versionCheck) {
        Write-Host "You are already running the latest version of Bicep CLI."
    }
    else {
        Uninstall-BicepCLI -Force -ErrorAction SilentlyContinue
        Install-BicepCLI -Force
    }
}
