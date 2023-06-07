

BeforeAll {
    $ScriptDirectory = Split-Path -Path $PSCommandPath -Parent
    Import-Module -FullyQualifiedName (Join-Path $PSScriptRoot '..\Source\Bicep.psd1') -ErrorAction Stop
}

Describe 'InstalledBicepVersion' {
    Context 'Bicep CLI installed' {
        BeforeAll {
            Mock TestBicep -ModuleName Bicep {
                $true
            }
        }

        It 'Returns correctly parsed version' {
            InModuleScope Bicep {
                # We cannot properly mock regular commands like bicep.exe
                # Instead, we use a function which kind of works like a mock, with very limited functionality
                function bicep {
                    'Bicep CLI version 0.12.987 (a13b032755)'
                }
                InstalledBicepVersion | Should -Be '0.12.987'
            }
        }
    }

    Context 'Bicep CLI not installed' {
        BeforeAll {
            Mock TestBicep -ModuleName Bicep {
                $false
            }
        }

        It 'Returns not installed message' {
            InModuleScope Bicep {
                InstalledBicepVersion | Should -Be 'Not installed'
            }
        }
    }
}
