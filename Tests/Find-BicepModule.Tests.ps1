Remove-Module Bicep -ErrorAction SilentlyContinue
Import-Module $PSScriptRoot\..\Source\Bicep

InModuleScope -ModuleName Bicep {
    Describe 'Find-BicepModule tests' {

        Context 'Parameters' {
            It 'Should have parameter Path' {
                (Get-Command Find-BicepModule).Parameters.Keys | Should -Contain 'Path'
            }
            It 'Should have parameter Registry' {
                (Get-Command Find-BicepModule).Parameters.Keys | Should -Contain 'Registry'
            }
            It 'Should have parameter Cache' {
                (Get-Command Find-BicepModule).Parameters.Keys | Should -Contain 'Cache'
            }
        }
    }
}
