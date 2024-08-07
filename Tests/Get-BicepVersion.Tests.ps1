BeforeAll {
    Import-Module -FullyQualifiedName "$PSScriptRoot\..\output\Bicep" -ErrorAction Stop
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
