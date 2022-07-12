function Get-BicepConfig {
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { Test-Path $_ })]
        [string]$Path,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("Local", "Merged", "Default")]
        [string]$Scope

    )
    begin {
        # Check if a newer version of the module is published
        if (-not $Script:ModuleVersionChecked) {
            TestModuleVersion
        }       
    }

    process {        
        
        if ($Scope -eq 'Default' -and -not $path) {
            Get-BicepNetConfig -Scope 'Default'
        }
        elseif ($Path) {
            $BicepFile = Resolve-Path -Path $Path
            if ($Scope) {
                Get-BicepNetConfig -Path $BicepFile -Scope $Scope 
            }
            else {
                try {
                    # Test if cusotm bicepconfig.json is present
                    Get-BicepNetConfig -Path $BicepFile
                }
                catch {
                    # Return default config if no custom bicepconfig.json is present
                    Get-BicepNetConfig -Scope 'Default'
                }
            }
        }
    }
}