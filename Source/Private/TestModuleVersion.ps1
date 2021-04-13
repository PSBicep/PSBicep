function TestModuleVersion {
        
    $BaseURL = 'https://api.github.com/repos/StefanIvemo/bicepPowershell/releases'
    try {        
        $LatestVersion = Invoke-RestMethod -Uri ('{0}/latest' -f $BaseURL)
        $LatestBicepVersion = $LatestVersion.tag_name -replace '[v]', ''
          
        $InstalledModuleVersion = (Get-Module -Name Bicep).Version | Sort-Object -Descending | Select-Object -First 1
        
        if ($LatestBicepVersion -ne $InstalledModuleVersion.ToString()) {
            Write-Host "A new version of the Bicep module ($LatestBicepVersion) is available. Update the module using 'Update-Module -Name Bicep'" -ForegroundColor 'DarkYellow'
        }
    }
    catch {
        Write-Verbose -Message "Could not get latest version from GitHub. $_"
    }
    
    $Script:ModuleVersionChecked = $true
    
}
