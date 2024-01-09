BeforeAll {
    Import-Module -FullyQualifiedName "$PSScriptRoot\..\Source\Bicep.psd1" -ErrorAction Stop
}

InModuleScope Bicep {
    Describe 'NewMDTableHeader' {
        Context 'When given an array of headers' {
            $headers = 'Name', 'Property', 'Value'
            $expectedOutput = '| Name | Property | Value |\n| ---- | --- | ------ |'

            It 'Returns a valid Markdown table header' {
                $result = NewMDTableHeader -Headers $headers
                $result | Should -Be $expectedOutput
            }
        }

        Context 'When given an empty array' {
            $headers = @()

            It 'throws an error' {
                { NewMDTableHeader -Headers $headers } | Should -Throw
            }
        }
    }
}