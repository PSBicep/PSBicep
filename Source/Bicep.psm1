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
        Write-Error "Cannot find the Bicep CLI. Install Bicep CLI using Install-BicepCLI"
    }
}

function Get-BicepVersion {
    $installedVersion = ((bicep --version) -split "\s+")[3]

    $latestVersion = Invoke-WebRequest -URI "https://api.github.com/repos/Azure/Bicep/releases/latest" | ConvertFrom-Json
    $latestVersion = $latestVersion.tag_name -replace '[v]', ''

    $version = @{
        InstalledVersion = $installedVersion
        LatestVersion    = $latestVersion
    }
    $versions = New-Object psobject -Property $version
    $versions 
}

function Install-BicepCLI {
    $bicep = (bicep --version)
    if (-not $bicep) {
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
        Write-Host "Bicep CLI is already installed. Use Update-BicepCLI to updated to the latest release"
    }
}

function Update-BicepCLI {
    $installedVersion = ((bicep --version) -split "\s+")[3]

    $latestVersion = Invoke-WebRequest -URI "https://api.github.com/repos/Azure/Bicep/releases/latest" | convertfrom-json
    $latestVersion = $latestVersion.tag_name -replace '[v]', ''

    if ($installedVersion = $latestVersion) {
        Write-Host "You are running the latest version of Bicep CLI"
    }
    else {
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
}