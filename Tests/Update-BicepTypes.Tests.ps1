BeforeAll {
    Import-Module -FullyQualifiedName "$PSScriptRoot\..\output\Bicep" -ErrorAction Stop
    New-Item -Path 'TestDrive:\' -Name 'Assets' -ItemType Directory
}

Describe 'Update-BicepTypes' {
    BeforeAll {
        Mock TestModuleVersion -ModuleName Bicep {
            $Script:ModuleVersionChecked = $true
        }

        Mock Write-Host -ModuleName Bicep {
            # we dont need output when running tests
        }

        Mock Get-Module -ModuleName Bicep {
            [PSCustomObject]@{
                Path = 'TestDrive:\Bicep.psm1'
            }
        }

        Mock Invoke-RestMethod -ModuleName Bicep {
            [PSCustomObject]@{
                Resources = @{ sample='sample' }
            }
        }
    }

    It 'Updates BicepTypes.json' {
        Update-BicepTypes
        Get-ChildItem -Path TestDrive:\Assets\BicepTypes.json | Should -Exist
    }

    It 'Throws expected error if file is not downloaded' {
        Mock Invoke-RestMethod -ModuleName Bicep {
            Throw 'Error'
        }

        { Update-BicepTypes } | Should -Throw "Unable to get new Bicep types from GitHub. Error"
    }

    It 'Throws expected error if Resources is not present in index file' {
        Mock Invoke-RestMethod -ModuleName Bicep {
            [PSCustomObject]@{
                NotResources = @{ sample='sample' }
            }
        }

        { Update-BicepTypes } | Should -Throw "Resources not found in index file."
    }

    It 'Throws expected error if conversion to json does not work'{
        Mock ConvertTo-Json -ModuleName Bicep {
            Throw 'Error'
        }

        { Update-BicepTypes } | Should -Throw "Unable to filter content. Index file might have changed. Error"
    }

    It 'Throws expected error if saving to disk fails' {
        Mock Out-File -ModuleName Bicep {
            Throw 'Error'
        }

        { Update-BicepTypes } | Should -Throw "Failed to save new Bicep types. Error"
    }
}