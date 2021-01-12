function Invoke-BicepBuild {
    param(
        [string]$Path = $pwd.path
    )

    $bicep = (bicep --version)
    if ($bicep) {
        $files = Get-Childitem -Path $Path *.bicep -File
        if ($files) {
            foreach ($file in $files) {
                bicep build $file
            }   
        }
        else {
            Write-Host "No bicep files located in path $Path"
        } 
    }
    else {
        Write-Error "Cannot find the Bicep CLI. Install Bicep CLI using Install-BicepCLI."
    }
}

function ConvertFrom-Bicep {
    param(
        [string]$Path = $pwd.path
    )

    $bicep = (bicep --version)
    if ($bicep) {
        $files = Get-Childitem -Path $Path *.json -File
        if ($files) {
            foreach ($file in $files) {
                bicep decompile $file
            }   
        }
        else {
            Write-Host "No bicep files located in path $Path"
        } 
    }
    else {
        Write-Error "Cannot find the Bicep CLI. Install Bicep CLI using Install-BicepCLI."
    }    
}


function Get-BicepVersion {
    $installedVersion = Get-InstalledBicepVersion
    $latestVersion = Get-LatestBicepVersion

    [pscustomobject]@{
        InstalledVersion = $installedVersion
        LatestVersion    = $latestVersion
    } 
}

function Install-BicepCLI {
    param(
        [switch]$Force
    )
    if (-not $Force.IsPresent) {
        try {
            bicep --version
            $BicepInstalled = $true
        }
        catch {
            $BicepInstalled = $false
        }
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
        $versionCheck = Compare-BicepVersion
        if ($versionCheck) {
            Write-Host "The latest Bicep CLI Version is already installed."
        }
        else {
            Write-Host "Bicep CLI is already installed, but there is a newer release available. Use Update-BicepCLI or Install-BicepCLI -Force to updated to the latest release"   
        }        
    }
}

function Update-BicepCLI {
    $versionCheck = Compare-BicepVersion

    if ($versionCheck) {
        Write-Host "You are already running the latest version of Bicep CLI."
    }
    else {
        Install-BicepCLI -Force
    }     
}

function Get-LatestBicepVersion {
    $latestVersion = Invoke-WebRequest -URI "https://api.github.com/repos/Azure/Bicep/releases/latest" | convertfrom-json
    $latestVersion.tag_name -replace '[v]', ''
}

function Get-InstalledBicepVersion {
    ((bicep --version) -split "\s+")[3]
}

function Compare-BicepVersion {
    $installedVersion = Get-InstalledBicepVersion
    $latestVersion = Get-LatestBicepVersion

    if ($installedVersion = $latestVersion) {
        $true
    }
    else {
        $false
    }
}