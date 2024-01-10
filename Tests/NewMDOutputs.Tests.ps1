BeforeAll {
    Import-Module -FullyQualifiedName "$PSScriptRoot\..\Source\Bicep.psd1" -ErrorAction Stop
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