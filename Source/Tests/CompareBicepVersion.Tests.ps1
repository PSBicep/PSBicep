try {
    $ScriptDirectory = Split-Path -Path $PSCommandPath -Parent
    Import-Module -FullyQualifiedName "$ScriptDirectory\..\Bicep.psd1"
}
catch {
    Throw "Unable to import Bicep module. $_"
}

InModuleScope Bicep { 
    Describe 'CompareBicepVersion' {
        BeforeAll {
            Mock LatestBicepVersion -ModuleName Bicep {
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
                CompareBicepVersion | Should -Be $true
            }
        }
        
        Context 'Old Bicep CLI installed' {
            BeforeAll {
                Mock InstalledBicepVersion -ModuleName Bicep {
                    return '0.1.2'
                }
            }

            It 'If older version is installed it should return $false' {
                CompareBicepVersion | Should -Be $false
            }
        }

        Context 'Bicep CLI not installed' {
            BeforeAll {
                Mock InstalledBicepVersion -ModuleName Bicep {
                    return 'Not installed'
                }
            }

            It 'If no version is installed it should return $false' {
                CompareBicepVersion | Should -Be $false
            }
        }
    }
}