BeforeAll {
    $ScriptDirectory = Split-Path -Path $PSCommandPath -Parent
    Import-Module -FullyQualifiedName (Join-Path $PSScriptRoot '..\Source\Bicep.psd1') -ErrorAction Stop
}
 
Describe 'CompareBicepVersion' {
    BeforeAll {
        Mock ListBicepVersions -ModuleName Bicep {
            throw "should not happen"
        }

        Mock ListBicepVersions -ModuleName Bicep -ParameterFilter { $Latest.IsPresent }  {
            return '0.3.1'
        }
    }

    Context 'Latest Bicep CLI installed' {
        BeforeAll {
            Mock InstalledBicepVersion -ModuleName Bicep {
                return '0.3.1'
            }
        }

        It 'If latest version is installed it should return $true' {
            InModuleScope Bicep {
                CompareBicepVersion | Should -Be $true
            }
        }
    }
    
    Context 'Old Bicep CLI installed' {
        BeforeAll {
            Mock InstalledBicepVersion -ModuleName Bicep {
                return '0.1.2'
            }
        }

        It 'If older version is installed it should return $false' {
            InModuleScope Bicep {
                CompareBicepVersion | Should -Be $false
            }
        }
    }

    Context 'Bicep CLI not installed' {
        BeforeAll {
            Mock InstalledBicepVersion -ModuleName Bicep {
                return 'Not installed'
            }
        }

        It 'If no version is installed it should return $false' {
            InModuleScope Bicep {
                CompareBicepVersion | Should -Be $false
            }
        }
    }
}
