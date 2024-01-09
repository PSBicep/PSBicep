BeforeAll {
    Import-Module -FullyQualifiedName "$PSScriptRoot\..\Source\Bicep.psd1" -ErrorAction Stop
}

InModuleScope Bicep {
    Describe 'NewMDMetadata' {
        Context 'when given null metadata' {
            It 'returns "n/a"' {
                $result = NewMDMetadata -Metadata $null
                $result | Should -Be 'n/a'
            }
        }
    }
}