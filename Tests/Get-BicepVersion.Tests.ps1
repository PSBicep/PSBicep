try {
    $ScriptDirectory = Split-Path -Path $PSCommandPath -Parent
    Import-Module -FullyQualifiedName "$ScriptDirectory\..\Source\Bicep.psd1"
}
catch {
    Throw "Unable to import Bicep module. $_"
}

Describe 'Get-BicepVersion' {
    BeforeAll {
        Mock TestModuleVersion -ModuleName Bicep  {
            $Script:ModuleVersionChecked = $true
        }

        Mock ListBicepVersions -ModuleName Bicep {
            'Version 1', 'Version 2', 'Version 3'
        }

        Mock ListBicepVersions -ModuleName Bicep -ParameterFilter { $Latest.IsPresent -eq $true } {
            'Version 3'
        } 
        
        Mock InstalledBicepVersion -ModuleName Bicep {
            'Version 2'
        }
    }
    
        Context 'First executed command after import' {
            It 'Checks for new version the first time only' {
                InModuleScope Bicep {
                    Mock TestModuleVersion {
                        $Script:ModuleVersionChecked = $true
                    }

                    $Script:ModuleVersionChecked = $false
                    
                    $null = Get-BicepVersion
                    $null = Get-BicepVersion    
                    Should -Invoke TestModuleVersion -ModuleName Bicep -Times 1 -Exactly
                }
            }
        }

    Context 'Verify -All switch' {
        It 'Invokes ListBicepVersions with -Latest when -All is not used' {
            Get-BicepVersion
            Should -Invoke ListBicepVersions -ModuleName Bicep -ParameterFilter {$Latest.IsPresent -eq $true}
        }

        It 'Invokes ListBicepVersions without -Latest when -All is used' {
            Get-BicepVersion -All
            Should -Invoke ListBicepVersions -ModuleName Bicep
        }

        It 'Invokes InstalledBicepVersion when -All switch is used' {
            Get-BicepVersion
            Should -Invoke InstalledBicepVersion -ModuleName Bicep
        }

        It 'Does not invoke InstalledBicepVersion when -All switch is omitted' {
            Get-BicepVersion -All
            Should -Not -Invoke InstalledBicepVersion -ModuleName Bicep
        }
    }

    Context 'Verify output' {
        BeforeAll {
            $Result = Get-BicepVersion
        }

        It 'Returns correct InstalledVersion' {
            $Result.InstalledVersion | Should -Be 'Version 2'
        }

        It 'Returns correct LatestVersion' {
            $Result.LatestVersion | Should -Be 'Version 3'
        }
    }
}
