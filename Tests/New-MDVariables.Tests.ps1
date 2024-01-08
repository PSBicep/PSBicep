BeforeAll {
    Import-Module -FullyQualifiedName "$PSScriptRoot\..\Source\Bicep.psd1" -Force -ErrorAction Stop
}

InModuleScope Bicep {
    Describe 'New-MDVariables' {
        Context 'when given null variables' {
            It 'returns "n/a"' {
                $result = New-MDVariables -Variables $null
                $result | Should -Be 'n/a'
            }
        }
    }
}