BeforeAll {
    Import-Module -FullyQualifiedName "$PSScriptRoot\..\output\Bicep" -ErrorAction Stop
}

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
