function LatestBicepVersion {
    $latestVersion = Invoke-RestMethod -URI "https://api.github.com/repos/Azure/Bicep/releases/latest" 
    $latestVersion.tag_name -replace '[v]', ''
}