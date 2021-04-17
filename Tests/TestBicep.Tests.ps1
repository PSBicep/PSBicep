
try {
    $ScriptDirectory = Split-Path -Path $PSCommandPath -Parent
    Import-Module -FullyQualifiedName "$ScriptDirectory\..\Source\Bicep.psd1"
}
catch {
    Throw "Unable to import Bicep module. $_"
}

InModuleScope Bicep { 
    Describe "TestBicep" {
    
        Context "Bicep CLI installed" {
            BeforeAll {
                Mock Get-Command {
                    'bicep is installed'
                }
            }
            
            It "Returns true when Bicep CLI is installed" {
                TestBicep | Should -Be $true
            }
        }
        
        Context "Bicep CLI not installed" {
            BeforeAll {
                Mock Get-Command {
                    Write-Error 'bicep not installed'
                }
            }

            It "Returns false when Bicep CLI is not installed" {
                TestBicep | Should -Be $false
            }
        }
    }
}