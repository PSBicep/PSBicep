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
        Write-Host "Downloading binaries"
        $DownloadFileName = 'bicep-win-x64.exe'
        $TargetFileName = "$installPath\bicep.exe"
        $GithubLatestAPIPath = 'https://api.github.com/repos/Azure/bicep/releases/latest'

        # Fetch data about latest Bicep release from Github API
        $LatestBicepRelease = Invoke-RestMethod -Uri $GithubLatestAPIPath
        $RequestedGithubAsset = $LatestBicepRelease.assets | Where-Object -Property Name -eq $DownloadFileName
        #Download and show progress.
        (New-Object Net.WebClient).DownloadFileAsync($RequestedGithubAsset.browser_download_url, $TargetFileName)
        do {
            $PercentComplete = [math]::Round((Get-Item $TargetFileName).Length / $RequestedGithubAsset.size * 100)
            Write-Progress -Activity 'Downloading Bicep' -PercentComplete $PercentComplete
            start-sleep 1
        } while ((Get-Item $TargetFileName).Length -lt $RequestedGithubAsset.size)

        # Add bicep to your PATH
        Write-Host "Installing Bicep CLI"
        $currentPath = (Get-Item -path "HKCU:\Environment" ).GetValue('Path', '', 'DoNotExpandEnvironmentNames')
        if (-not $currentPath.Contains("%USERPROFILE%\.bicep")) { setx PATH ($currentPath + ";%USERPROFILE%\.bicep") }
        if (-not $env:path.Contains($installPath)) { $env:path += ";$installPath" }
        # Verify you can now access the 'bicep' command.
        if (TestBicep){
            $bicep=(bicep --version)
            Write-Host "$bicep successfully installed!"
        } else {
            Write-Error "Error installing Bicep CLI"
        }
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