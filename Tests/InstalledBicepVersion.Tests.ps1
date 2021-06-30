

BeforeAll {
    $ScriptDirectory = Split-Path -Path $PSCommandPath -Parent
    Import-Module -FullyQualifiedName "$ScriptDirectory\..\Source\Bicep.psd1" -ErrorAction Stop
}

InModuleScope Bicep { 
    Describe 'InstalledBicepVersion' {
        Context 'Bicep CLI installed' {
            BeforeAll {
                # We cannot properly mock regular commands like bicep.exe
                # Instead, we use a function which kind of works like a mock, with very limited functionality
                function bicep {
                    'Bicep CLI version 0.12.987 (a13b032755)'
                }

                Mock TestBicep -ModuleName Bicep {
                    $true
                }
            }

            It 'Returns correctly parsed version' {
                InstalledBicepVersion | Should -Be '0.12.987'
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