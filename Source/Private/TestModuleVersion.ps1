function TestModuleVersion {

    $Script:ModuleVersionChecked = $true
    if($null -eq $Script:LatestModuleVersion) {
        try {
            $Script:LatestModuleVersion = GetGithubReleaseVersion -Organization 'PSBicep' -Repository 'PSBicep' -Latest -ErrorAction 'Stop'
        }
        catch {
            $Script:LatestModuleVersion = ''
            Write-Verbose "Failed to retrieve latest version with error: $_"
        }
    }

    try {

        $InstalledModuleVersion = (Get-Module -Name Bicep).Version | Sort-Object -Descending | Select-Object -First 1
        
        if($Script:LatestModuleVersion -is [version]) {
            if([version]$LatestModuleVersion -gt $InstalledModuleVersion) {
                Write-Host "A new version of the Bicep module ($Script:LatestModuleVersion) is available. Update the module using 'Update-Module -Name Bicep'" -ForegroundColor 'DarkYellow'
            }
        }
    }
    catch {
        Write-Verbose -Message "Could not find a newer version of the module. $_"
    }
    
}
