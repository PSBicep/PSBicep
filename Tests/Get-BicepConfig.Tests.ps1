BeforeAll {
    $ScriptDirectory = Split-Path -Path $PSCommandPath -Parent
    Import-Module -FullyQualifiedName "$ScriptDirectory\..\Source\Bicep.psd1" -ErrorAction Stop

    Copy-Item "$ScriptDirectory\supportFiles\*" -Destination TestDrive:\
}

InModuleScope -ModuleName Bicep {
    Describe 'Get-BicepConfig tests' {

        Context 'Parameters' {
            It 'Should have parameter Path' {
                (Get-Command Get-BicepConfig).Parameters.Keys | Should -Contain 'Path'
            }
        }

        Context 'Finding bicepconfigs' {
                    
            It 'Should find bicepconfig file' {
                $BicepConfig = Get-Content -Path 'TestDrive:\bicepconfig.json'
                $BicepConfig | Should -Not -BeNullOrEmpty
            }

            It 'Should find default bicepconfig' {
                $BicepConfig = Get-BicepConfig -Path "C:\"
                $BicepConfig.Path | Should -Be "Default"
            }
            
            It 'Should find custom bicepconfig' {
                $BicepConfig = Get-BicepConfig -Path "$TestDrive\workingBicep.bicep"
                $BicepConfig.Path | Should -BeLike "*bicepconfig.json"
            }

        }
    }
}