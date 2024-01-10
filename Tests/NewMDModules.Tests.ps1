BeforeAll {
    Import-Module -FullyQualifiedName "$PSScriptRoot\..\Source\Bicep.psd1" -ErrorAction Stop
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