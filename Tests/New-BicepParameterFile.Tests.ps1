BeforeAll {
    Import-Module -FullyQualifiedName "$PSScriptRoot\..\output\Bicep" -ErrorAction Stop
    Copy-Item "$PSScriptRoot\supportFiles\*" -Destination TestDrive:\
}

Describe 'New-BicepParameterFile' {
    Context 'Parameters' {
        It 'Should have parameter Path' {
            (Get-Command New-BicepParameterFile).Parameters.Keys | Should -Contain 'Path'
        }
        It 'Should have parameter Parameters' {
            (Get-Command New-BicepParameterFile).Parameters.Keys | Should -Contain 'Parameters'
        }
        It 'Should have parameter OutputDirectory' {
            (Get-Command New-BicepParameterFile).Parameters.Keys | Should -Contain 'OutputDirectory'
        }
    }
    
    Context 'When it works' {            
        It 'Parameter file manadatory' {
            $file='TestDrive:\workingBicep.bicep'
            New-BicepParameterFile -Path $file -Parameters Required
            $parameterFile = $file -replace '\.bicep', '.parameters.json'
            Get-Content -Path $parameterFile -Raw | ConvertFrom-Json | Should -Not -BeNullOrEmpty
        }

        It 'Parameter file all' {
            $file='TestDrive:\workingBicep.bicep'
            New-BicepParameterFile -Path $file -Parameters All
            $parameterFile = $file -replace '\.bicep', '.parameters.json'
            Get-Content -Path $parameterFile -Raw | ConvertFrom-Json | Should -Not -BeNullOrEmpty
        }

    }
    Context 'When it does not work' { 
        It 'Does not generate parameter file' {
            { New-BicepParameterFile -Path 'TestDrive:\brokenBicep.bicep' -ErrorAction Stop } | Should -Throw
        }

        It 'Error message works' {
            try {
                New-BicepParameterFile -Path 'TestDrive:\brokenBicep.bicep' -ErrorAction Stop
            }
            catch {
                $_.Exception.Message | Should -BeLike '*Error BCP018: Expected the "}" character at this location.'
            }
        }
    }
}