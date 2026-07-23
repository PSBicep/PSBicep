Import-Module 'PSDepend', 'Metadata', 'Microsoft.PowerShell.PSResourceGet' -ErrorAction 'Stop'

$RequiredModulesPath = './RequiredModules.psd1'
$RequiredModulesMetadata = ConvertFrom-Metadata -InputObject $RequiredModulesPath -Ordered
$PSGalleryDependencies = Get-Dependency -Path $RequiredModulesPath | Where-Object 'DependencyType' -eq 'PSGalleryModule'


$UpdatesFound = $false

foreach ($dependency in $PSGalleryDependencies) {
    $latest = Find-PSResource -Name $dependency.DependencyName -Type 'Module' -Repository 'PSGallery'
    if ($latest.Version -gt $dependency.Version) {
        Write-Host "Update found for $($dependency.DependencyName): $($dependency.Version) -> $($latest.Version)"
        $UpdatesFound = $true
        $RequiredModulesMetadata[$dependency.DependencyName] = $latest.Version.ToString()
    }
}

if ($UpdatesFound) {
    $RequiredModulesMetadata | ConvertTo-Metadata | Out-File -FilePath $RequiredModulesPath -Encoding 'UTF8' -Force
}