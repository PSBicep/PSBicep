function LatestBicepVersion {
    $latestVersion = Invoke-WebRequest -URI "https://api.github.com/repos/Azure/Bicep/releases/latest" | convertfrom-json
    $latestVersion.tag_name -replace '[v]', ''
}