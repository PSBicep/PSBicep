Import-Module -FullyQualifiedName "$PSScriptRoot\..\output\Bicep" -ErrorAction Stop

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