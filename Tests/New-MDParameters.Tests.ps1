BeforeAll {
    Import-Module -FullyQualifiedName "$PSScriptRoot\..\Source\Bicep.psd1" -ErrorAction Stop
}
InModuleScope Bicep {
    Describe 'New-MDParameters' {
        Context 'when given null parameters' {
            It 'returns "n/a"' {
                $result = New-MDParameters -Parameters $null
                $result | Should -Be 'n/a'
            }
        }
    }
}