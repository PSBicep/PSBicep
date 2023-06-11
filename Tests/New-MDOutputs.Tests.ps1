BeforeAll {
    Import-Module -FullyQualifiedName "$PSScriptRoot\..\Source\Bicep.psd1" -ErrorAction Stop
}
InModuleScope Bicep {
    Describe 'New-MDOutputs' {
        Context 'when given null outputs' {
            It 'returns "n/a"' {
                $result = New-MDOutputs -Outputs $null
                $result | Should -Be 'n/a'
            }
        }
    }
}