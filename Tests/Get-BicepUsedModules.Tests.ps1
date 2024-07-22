# Data driven https://pester.dev/docs/usage/data-driven-tests
BeforeAll {
    Import-Module -FullyQualifiedName "$PSScriptRoot\..\output\Bicep" -ErrorAction Stop
}


Describe 'Get-BicepUsedModules' -ForEach @(
    @{
        name     = 'bicepWithMeta.bicep'
        fullName = "$PSScriptRoot\supportFiles\bicepWithMeta.bicep"
        count    = 0
    }
    @{
        name     = 'main.bicep'
        fullName = "$PSScriptRoot\supportFiles\main.bicep"
        count    = 1
    },
    @{
        name     = 'workingBicep.bicep'
        fullName = "$PSScriptRoot\supportFiles\workingBicep.bicep"
        count    = 0
    }
) {

    It '<name> should find <count> modules used in the bicep file' {

        $result = Get-BicepUsedModules -Path $_.fullName
        $Count = $_.count
        @($result).Count | Should -Be $Count
    }
}

Describe 'Get-BicepUsedModules' {
    It 'should throw an error if the file does not exist' {
        $result = Get-BicepUsedModules -Path 'doesnotexist.bicep' -ErrorAction SilentlyContinue
        $result | Should -BeNullOrEmpty
    }
}
