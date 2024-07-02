BeforeAll {
    Import-Module -FullyQualifiedName "$PSScriptRoot\..\output\Bicep" -ErrorAction Stop
}
InModuleScope Bicep {
    Describe 'NewMDOutputs' {
        Context 'when given null outputs' {
            It 'returns "n/a"' {
                $result = NewMDOutputs -Outputs $null
                $result | Should -Be 'n/a'
            }
        }
    }
}