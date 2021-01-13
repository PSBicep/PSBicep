<#
.SYNOPSIS
    Install Bicep CLI
.DESCRIPTION
    Install-BicepCLI is a command to to install the latest Bicep CLI realease available from the Azure/Bicep repo.
.PARAMETER Force
    Specifies if Bicep CLI should be installed using force
.EXAMPLE
    Install-BicepCLI
    Install Bicep CLI
.EXAMPLE
    Install-BicepCLI -Force
    Install Bicep CLI
.NOTES
    Go to module repository https://github.com/StefanIvemo/BicepPowerShell for detailed info, reporting issues and to submit contributions.
#>
function Install-BicepCLI {
    param(
        [switch]$Force
    )
    if (-not $Force.IsPresent) {
        $BicepInstalled=TestBicep
    }
    if ($Force.IsPresent -or $BicepInstalled -eq $false) {
        # Create the install folder
        $installPath = "$env:USERPROFILE\.bicep"
        $installDir = New-Item -ItemType Directory -Path $installPath -Force
        $installDir.Attributes += 'Hidden'
        # Fetch the latest Bicep CLI binary
        (New-Object Net.WebClient).DownloadFile("https://github.com/Azure/bicep/releases/latest/download/bicep-win-x64.exe", "$installPath\bicep.exe")
        # Add bicep to your PATH
        $currentPath = (Get-Item -path "HKCU:\Environment" ).GetValue('Path', '', 'DoNotExpandEnvironmentNames')
        if (-not $currentPath.Contains("%USERPROFILE%\.bicep")) { setx PATH ($currentPath + ";%USERPROFILE%\.bicep") }
        if (-not $env:path.Contains($installPath)) { $env:path += ";$installPath" }
        # Verify you can now access the 'bicep' command.
        bicep --help
        # Done!
    }
    else {
        $versionCheck = CompareBicepVersion
        if ($versionCheck) {
            Write-Host "The latest Bicep CLI Version is already installed."
        }
        else {
            Write-Host "Bicep CLI is already installed, but there is a newer release available. Use Update-BicepCLI or Install-BicepCLI -Force to updated to the latest release"   
        }        
    }
}