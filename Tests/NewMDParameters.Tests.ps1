BeforeAll {
    Import-Module -FullyQualifiedName "$PSScriptRoot\..\output\module\Bicep" -ErrorAction Stop
}
InModuleScope Bicep {
    Describe 'NewMDParameters' {
        Context 'when given null parameters' {
            It 'returns "n/a"' {
                $result = NewMDParameters -Parameters $null
                $result | Should -Be 'n/a'
            }
        }
    }
}