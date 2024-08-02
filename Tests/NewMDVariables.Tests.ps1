BeforeAll {
    Import-Module -FullyQualifiedName "$PSScriptRoot\..\output\Bicep" -ErrorAction Stop
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