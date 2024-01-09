BeforeAll {
    Import-Module -FullyQualifiedName "$PSScriptRoot\..\Source\Bicep.psd1" -ErrorAction Stop
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