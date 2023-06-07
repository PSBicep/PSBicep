BeforeAll {
    $ScriptDirectory = Split-Path -Path $PSCommandPath -Parent
    Import-Module -FullyQualifiedName (Join-Path $PSScriptRoot '..\Source\Bicep.psd1') -ErrorAction Stop
}

Describe "TestBicep" {
    Context "Bicep CLI installed" {
        BeforeAll {
            Mock Get-Command -ModuleName Bicep {
                'bicep is installed'
            }
        }
        
        It "Returns true when Bicep CLI is installed" {
            InModuleScope Bicep {
                TestBicep | Should -Be $true
            }
        }
    }
    
    Context "Bicep CLI not installed" {
        BeforeAll {
            Mock Get-Command -ModuleName Bicep { }
        }

        It "Returns false when Bicep CLI is not installed" {
            InModuleScope Bicep {
                TestBicep | Should -Be $false
            }
        }
    }
}
