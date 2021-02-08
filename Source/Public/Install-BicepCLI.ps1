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
    [CmdLetBinding()]
    param(
        [switch]$Force
    )
    if (-not $Force.IsPresent) {
        $BicepInstalled=TestBicep
    }
    if ($Force.IsPresent -or $BicepInstalled -eq $false) {
        # Fetch the latest Bicep CLI installer
        $DownloadFileName = 'bicep-setup-win-x64.exe'
        $TargetFileName = Join-Path -Path $env:TEMP -ChildPath $DownloadFileName
        $GithubLatestAPIPath = 'https://api.github.com/repos/Azure/bicep/releases/latest'

        # Fetch data about latest Bicep release from Github API
        $LatestBicepRelease = Invoke-RestMethod -Uri $GithubLatestAPIPath
        $RequestedGithubAsset = $LatestBicepRelease.assets | Where-Object -Property Name -eq $DownloadFileName
        #Download and show progress.
        (New-Object Net.WebClient).DownloadFileAsync($RequestedGithubAsset.browser_download_url, $TargetFileName)
        Write-Verbose "Downloading $($RequestedGithubAsset.browser_download_url) to location $TargetFileName"
        do {
            $PercentComplete = [math]::Round((Get-Item $TargetFileName).Length / $RequestedGithubAsset.size * 100)
            Write-Progress -Activity 'Downloading Bicep' -PercentComplete $PercentComplete
            start-sleep 1
        } while ((Get-Item $TargetFileName).Length -lt $RequestedGithubAsset.size)

        # Run the installer in silent mode
        Write-Verbose "Running installer $TargetFileName /VERYSILENT"
        & $TargetFileName /VERYSILENT
        $i = 0
        do {
            $i++
            Write-Progress -Activity 'Installing Bicep CLI' -CurrentOperation "$i - Running $DownloadFileName" 
            Start-Sleep -Seconds 1
        } while (Get-Process $DownloadFileName.Replace('.exe','') -ErrorAction SilentlyContinue)   

        # Since bicep installer updates the $env:PATH we reload it in order to verify installation.
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        
        # Verify you can now access the 'bicep' command.
        if (TestBicep){
            $bicep = InstalledBicepVersion
            Write-Host "Bicep version $bicep successfully installed!"
        } else {
            Write-Error "Error installing Bicep CLI"
        }

        # Remove the downloaded installer.
        Remove-Item $TargetFileName -ErrorAction SilentlyContinue -Force
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