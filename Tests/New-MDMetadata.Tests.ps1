BeforeAll {
    Import-Module -FullyQualifiedName "$PSScriptRoot\..\Source\Bicep.psd1" -ErrorAction Stop
}

InModuleScope Bicep {
    Describe 'New-MDMetadata' {
        Context 'when given null metadata' {
            It 'returns "n/a"' {
                $result = New-MDMetadata -Metadata $null
                $result | Should -Be 'n/a'
            }
        }
    }
}