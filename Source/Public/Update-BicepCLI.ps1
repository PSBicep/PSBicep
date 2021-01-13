function Update-BicepCLI {
    $versionCheck = CompareBicepVersion

    if ($versionCheck) {
        Write-Host "You are already running the latest version of Bicep CLI."
    }
    else {
        Install-BicepCLI -Force
    }     
}