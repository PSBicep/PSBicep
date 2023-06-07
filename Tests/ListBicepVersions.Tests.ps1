
BeforeAll {
    $ScriptDirectory = Split-Path -Path $PSCommandPath -Parent
    Import-Module -FullyQualifiedName (Join-Path $PSScriptRoot '..\Source\Bicep.psd1') -ErrorAction Stop
}

Describe 'ListBicepVersions' {

    Context 'When it works' {
        
        BeforeAll {
            Mock Invoke-RestMethod -ModuleName Bicep {
                if ($Uri -like '*latest') {
                    @{ tag_name = 'v1.2.3' }
                } else {
                    @{ tag_name = 'v1.2.3' }
                    @{ tag_name = 'v1.2.2' }
                    @{ tag_name = 'v1.2.1' }
                }
            }
        }

        It 'Returns correct latest version' {
            InModuleScope Bicep {
                ListBicepVersions -Latest | Should -Be '1.2.3'
            }
        }

        It 'Returns all versions' {
            InModuleScope Bicep {
                $versions = ListBicepVersions
                $versions.count | Should -Be 3
            }
        }
    }

    Context 'When it does not work' {
        
        BeforeAll {
            Mock Invoke-RestMethod -ModuleName Bicep {
                Throw 'Not working'
            }
        }

        It 'Throws error if unable to get latest version file from GitHub' {
            InModuleScope Bicep {
                { ListBicepVersions -Latest -ErrorAction Stop } | Should -Throw "Could not get latest version from GitHub.*"
            }
        }

        It 'Throws error if unable to get all version files from GitHub' {
            InModuleScope Bicep {
                { ListBicepVersions -ErrorAction Stop } | Should -Throw "Could not get versions from GitHub.*"
            }
        }

    }
}
