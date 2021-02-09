try {
    $ScriptDirectory = Split-Path -Path $PSCommandPath -Parent
    Import-Module -FullyQualifiedName "$ScriptDirectory\..\Bicep.psd1"
}
catch {
    Throw "Unable to import Bicep module. $_"
}

InModuleScope Bicep { 
    Describe 'InstalledBicepVersion' {
        Context 'Bicep CLI installed' {
            BeforeAll {
                Mock TestBicep -ModuleName Bicep {
                    $true
                }

                Mock bicep {
                    'Bicep CLI version 0.2.328 (a13b032755)'
                }
            }

            It 'Returns correctly parsed version' {
                InstalledBicepVersion | Should -Be '0.2.328'
            }
        }

        Context 'Bicep CLI not installed' {
            BeforeAll {
                Mock TestBicep -ModuleName Bicep {
                    $false
                }
            }

            It 'Returns not installed message' {
                InstalledBicepVersion | Should -Be 'Not installed'
            }
        }
    }
}