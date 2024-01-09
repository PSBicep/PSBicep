# Data driven https://pester.dev/docs/usage/data-driven-tests
BeforeAll {
    Import-Module -FullyQualifiedName "$PSScriptRoot\..\Source\Bicep.psd1" -ErrorAction Stop -Force
}


Describe 'Get-BicepUsedModules' -ForEach @(
    @{
        name     = 'bicepWithMeta.bicep'
        fullName = "$PSScriptRoot\supportFiles\bicepWithMeta.bicep"
    }
    @{
        name     = 'main.bicep'
        fullName = "$PSScriptRoot\supportFiles\main.bicep"
    },
    @{
        name     = 'workingBicep.bicep'
        fullName = "$PSScriptRoot\supportFiles\workingBicep.bicep"
    }
) {

    It '<name> should find modules used in the bicep file' {

        $result = Get-BicepUsedModules -Path $_.fullName

        switch ($_.Name) {
            'bicepWithMeta.bicep' {
                $result | Should -Be @()
            }
            'main.bicep' {
                $expected = [PSCustomObject]@{
                    Name = 'storage'
                    Path = 'workingBicep.bicep'
                } 
                $expectedJson = $expected | ConvertTo-Json -Depth 100
                $resultJson = $result | ConvertTo-Json -Depth 100
                $resultJson | Should -Be $expectedJson
            }
            'workingBicep.bicep' {
                $result | Should -Be @()
            }
            default {
                throw "Unknown file name: $($_.name)"
            }
        }
    }
}

Describe 'Get-BicepUsedModules' {
    It 'should throw an error if the file does not exist' {
        $result = Get-BicepUsedModules -Path 'doesnotexist.bicep' -ErrorAction SilentlyContinue
        $result | Should -BeNullOrEmpty
    }
}
