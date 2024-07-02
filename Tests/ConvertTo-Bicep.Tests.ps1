BeforeAll {
    Import-Module -FullyQualifiedName "$PSScriptRoot\..\output\Bicep" -ErrorAction Stop
    Copy-Item "$PSScriptRoot\supportFiles\*" -Destination TestDrive:\
}

Describe 'ConvertTo-Bicep' {
    
    Context 'Parameters' {
        It 'Should have parameter Path' {
            (Get-Command ConvertTo-Bicep).Parameters.Keys | Should -Contain 'Path'
        }
        It 'Should have parameter OutputDirectory' {
            (Get-Command ConvertTo-Bicep).Parameters.Keys | Should -Contain 'OutputDirectory'
        }
        It 'Should have parameter AsString' {
            (Get-Command ConvertTo-Bicep).Parameters.Keys | Should -Contain 'AsString'
        }
        It 'Should have parameter Force' {
            (Get-Command ConvertTo-Bicep).Parameters.Keys | Should -Contain 'Force'
        }
    }
    
    Context 'When it works' {            
        It 'Convert to bicep file AsString' {
            ConvertTo-Bicep -Path 'TestDrive:\workingARM.json' -AsString | Should -BeOfType System.String
        }

        It 'Convert to bicep file' {
            $file='TestDrive:\workingARM.json'
            ConvertTo-Bicep -Path $file
            $templateFile = $file -replace '\.json', '.bicep'
            Get-Content -Path $templateFile -Raw | Should -Not -BeNullOrEmpty
        }

    }
    Context 'When it does not work' { 
        It 'Does not generate bicep file' {
            { ConvertTo-Bicep -Path 'TestDrive:\brokenARM.json' -AsString -ErrorAction Stop } | Should -Throw
        }

        It 'Error message works' {
            try {
                ConvertTo-Bicep -Path 'TestDrive:\brokenARM.json' -AsString -ErrorAction Stop
            }
            catch {
                $_.Exception.Message | Should -BeLike '*Unexpected end of content while loading JObject. Path*'
            }
        }
    }
}