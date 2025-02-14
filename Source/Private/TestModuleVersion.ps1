function TestModuleVersion {

    if ($null -eq $Script:LatestModuleVersion) {
        try {
            $Script:LatestModuleVersion = GetGithubReleaseVersion -Organization 'PSBicep' -Repository 'PSBicep' -Latest -ErrorAction 'Stop'

            $ModuleManifest = Import-PowerShellDataFile -Path $Script:ModuleManifestPath
            $InstalledModuleVersion = $ModuleManifest.ModuleVersion
            Write-Verbose "Installed module version: $InstalledModuleVersion"
            if ($Script:LatestModuleVersion -is [version]) {
                if ([version]$LatestModuleVersion -gt $InstalledModuleVersion) {
                    Write-Host "A new version of the Bicep module ($Script:LatestModuleVersion) is available. Update the module using 'Update-Module -Name Bicep'" -ForegroundColor 'DarkYellow'
                }
            }
        }
        catch {
            $Script:LatestModuleVersion = ''
            Write-Verbose "Failed to retrieve latest version with error: $_"
        }
    }
}
