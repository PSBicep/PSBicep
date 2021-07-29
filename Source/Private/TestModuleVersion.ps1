function TestModuleVersion {
        
    $BaseURL = 'https://api.github.com/repos/PSBicep/PSBicep/releases'
    try {        
        $LatestVersion = Invoke-RestMethod -Uri ('{0}/latest' -f $BaseURL) -TimeoutSec 1 -Verbose:$false
        $LatestBicepVersion = $LatestVersion.tag_name -replace '[v]', ''

        $InstalledModuleVersion = (Get-Module -Name Bicep).Version | Sort-Object -Descending | Select-Object -First 1
        
        if($LatestBicepVersion -as [version]) {
            if([version]$LatestBicepVersion -gt $InstalledModuleVersion) {
                Write-Host "A new version of the Bicep module ($LatestBicepVersion) is available. Update the module using 'Update-Module -Name Bicep'" -ForegroundColor 'DarkYellow'
            }
        }
        else {
            Write-Host "Failed to compare Bicep module version. Latest version is $LatestBicepVersion. Update the module using 'Update-Module -Name Bicep'" -ForegroundColor 'DarkYellow'
        }
    }
    catch {
        Write-Verbose -Message "Could not find a newer version of the module. $_"
    }
    
    $Script:ModuleVersionChecked = $true
    
}
