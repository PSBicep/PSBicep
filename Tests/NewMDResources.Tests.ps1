BeforeAll {
    Import-Module -FullyQualifiedName "$PSScriptRoot\..\output\module\Bicep" -ErrorAction Stop
}

InModuleScope Bicep {
    Describe 'NewMDResources' {
        Context 'when given null resources' {
            It 'returns "n/a"' {
                $result = NewMDResources -Resources $null
                $result | Should -Be 'n/a'
            }
        }
    }
}