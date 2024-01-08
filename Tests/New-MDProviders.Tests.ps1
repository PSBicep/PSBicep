BeforeAll {
    Import-Module -FullyQualifiedName "$PSScriptRoot\..\Source\Bicep.psd1" -ErrorAction Stop
}
InModuleScope Bicep {
    Describe 'New-MDProviders' {
        Context 'when given null providers' {
            It 'returns "n/a"' {
                $result = New-MDProviders -Providers $null
                $result | Should -Be 'n/a'
            }
        }
    }
}