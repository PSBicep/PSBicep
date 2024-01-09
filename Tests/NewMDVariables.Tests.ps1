BeforeAll {
    Import-Module -FullyQualifiedName "$PSScriptRoot\..\Source\Bicep.psd1" -Force -ErrorAction Stop
}

InModuleScope Bicep {
    Describe 'NewMDVariables' {
        Context 'when given null variables' {
            It 'returns "n/a"' {
                $result = NewMDVariables -Variables $null
                $result | Should -Be 'n/a'
            }
        }
    }
}