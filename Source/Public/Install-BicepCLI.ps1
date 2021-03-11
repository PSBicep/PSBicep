function Install-BicepCLI {
    [CmdLetBinding()]
    param(
        [ValidateScript( { (ListBicepVersions).Contains($_) }, 
            ErrorMessage = "Bicep Version '{0}' was not found.")]
        [ArgumentCompleter([BicepVersionCompleter])]
        [string]$Version,
        [switch]$Force        
    )
    
    $BicepInstalled = TestBicep
    
    $BaseURL = 'https://api.github.com/repos/Azure/bicep/releases'
    if ($PSBoundParameters.ContainsKey('Version')) {
        $BicepRelease = ('{0}/tags/v{1}' -f $BaseURL, $Version)  
    }
    else {
        $BicepRelease = ('{0}/latest' -f $BaseURL)
    }
        
    if ($Force.IsPresent -and $BicepInstalled -eq $true) {
        Write-Warning 'You are running multiple installations of Bicep CLI. You can correct this by running Update-BicepCLI.'
    }

    if ($Force.IsPresent -or $BicepInstalled -eq $false) {
        # Fetch the latest Bicep CLI installer
        $DownloadFileName = 'bicep-setup-win-x64.exe'
        $TargetFileName = Join-Path -Path $env:TEMP -ChildPath $DownloadFileName

        # Fetch data about latest Bicep release from Github API
        $GetBicepRelease = Invoke-RestMethod -Uri $BicepRelease
        $RequestedGithubAsset = $GetBicepRelease.assets | Where-Object -Property Name -eq $DownloadFileName
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
        Start-Process $TargetFileName -ArgumentList '/VERYSILENT' -Wait
        $i = 0
        do {
            $i++
            Write-Progress -Activity 'Installing Bicep CLI' -CurrentOperation "$i - Running $DownloadFileName" 
            Start-Sleep -Seconds 1
        } while (Get-Process $DownloadFileName.Replace('.exe', '') -ErrorAction SilentlyContinue)   

        # Since bicep installer updates the $env:PATH we reload it in order to verify installation.
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        
        # Verify you can now access the 'bicep' command.
        if (TestBicep) {
            $bicep = InstalledBicepVersion
            Write-Host "Bicep version $bicep successfully installed!"
        }
        else {
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
