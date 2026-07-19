BeforeAll {
    Import-Module -FullyQualifiedName "$PSScriptRoot\..\output\module\Bicep" -ErrorAction Stop
}
InModuleScope Bicep {
    Describe 'NewMDProviders' {
        Context 'when given null providers' {
            It 'returns "n/a"' {
                $result = NewMDProviders -Resources $null
                $result | Should -Be 'n/a'
            }
        }
    }
}