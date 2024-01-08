BeforeAll {
    Import-Module -FullyQualifiedName "$PSScriptRoot\..\Source\Bicep.psd1" -ErrorAction Stop
}
InModuleScope Bicep {
    Describe 'New-MDModules' {
        Context 'when given null modules' {
            It 'returns "n/a"' {
                $result = New-MDModules -Modules $null
                $result | Should -Be 'n/a'
            }
        }
    }
}