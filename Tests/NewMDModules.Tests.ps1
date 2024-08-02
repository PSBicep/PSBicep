BeforeAll {
    Import-Module -FullyQualifiedName "$PSScriptRoot\..\output\Bicep" -ErrorAction Stop
}
InModuleScope Bicep {
    Describe 'NewMDModules' {
        Context 'when given null modules' {
            It 'returns "n/a"' {
                $result = NewMDModules -Modules $null
                $result | Should -Be 'n/a'
            }
        }
    }
}