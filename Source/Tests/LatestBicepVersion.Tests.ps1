try {
    $ScriptDirectory = Split-Path -Path $PSCommandPath -Parent
    Import-Module -FullyQualifiedName "$ScriptDirectory\..\Bicep.psd1"
}
catch {
    Throw "Unable to import Bicep module. $_"
}

InModuleScope Bicep {
    Describe 'LatestBicepVersion' {
        
        Context 'When it works' {
            
            BeforeAll {
                Mock Invoke-RestMethod {
                    [PSCustomObject]@{
                        tag_name = 'v1.2.3'
                    }
                }
            }

            It 'Returns correct version' {
                LatestBicepVersion | Should -Be '1.2.3'
            }
        }

        Context 'When it does not work' {
           
            BeforeAll {
                Mock Invoke-RestMethod {
                    Write-Error 'Not working'
                }
            }

            It 'Throws error if unable to get version file from GitHub' {
                { LatestBicepVersion -ErrorAction Stop } | Should -Throw "Could not get latest version from GitHub.*"
            }

        }
    }
}