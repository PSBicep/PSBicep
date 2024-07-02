BeforeAll {
    Import-Module -FullyQualifiedName "$PSScriptRoot\..\output\Bicep" -ErrorAction Stop
}
InModuleScope Bicep {
    Describe 'NewMDProviders' {
        Context 'when given null providers' {
            It 'returns "n/a"' {
                $result = NewMDProviders -Providers $null
                $result | Should -Be 'n/a'
            }
        }
    }
}