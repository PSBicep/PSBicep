
BeforeAll {
    $ScriptDirectory = Split-Path -Path $PSCommandPath -Parent
    Import-Module -FullyQualifiedName "$ScriptDirectory\..\Source\Bicep.psd1" -ErrorAction Stop
}



    Describe 'ListBicepVersions' {
        
        Context 'When it works' {
            
            BeforeAll {
                Mock Invoke-RestMethod -ModuleName Bicep {
                    [PSCustomObject]@{
                        tag_name = 'v1.2.3'
                    }
                }
            }

            It 'Returns correct version' {
                InModuleScope Bicep {
                    ListBicepVersions -Latest | Should -Be '1.2.3'
                }
            }
        }

        Context 'When it does not work' {
           
            BeforeAll {
                Mock Invoke-RestMethod -ModuleName Bicep {
                    Throw 'Not working'
                }
            }

            It 'Throws error if unable to get version file from GitHub' {
                InModuleScope Bicep {
                    { ListBicepVersions -Latest -ErrorAction Stop } | Should -Throw "Could not get latest version from GitHub.*"
                }
            }

        }
    }
