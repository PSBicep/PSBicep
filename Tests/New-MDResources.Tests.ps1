BeforeAll {
    Import-Module -FullyQualifiedName "$PSScriptRoot\..\Source\Bicep.psd1" -ErrorAction Stop
}

InModuleScope Bicep {
    Describe 'New-MDResources' {
        Context 'when given null resources' {
            It 'returns "n/a"' {
                $result = New-MDResources -Resources $null
                $result | Should -Be 'n/a'
            }
        }
    }
}