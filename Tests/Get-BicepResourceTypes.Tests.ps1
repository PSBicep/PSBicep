BeforeAll {
    Import-Module -FullyQualifiedName "$PSScriptRoot\..\output\module\Bicep" -ErrorAction Stop
}

Describe 'Bicep resource type exact matching' {
    It 'does not include provider prefix matches' {
        $result = @(Get-BicepResourceProvider -ResourceProvider Microsoft.Storage -ExactMatch)

        $result.Count | Should -Be 1
        $result[0] | Should -BeExactly 'Microsoft.Storage'
    }

    It 'does not include resource types from another provider' {
        Get-BicepResourceType -ResourceProvider Microsoft.Storage -Resource caches -ExactMatch |
            Should -BeNullOrEmpty
    }

    It 'does not fall back to a child prefix match' {
        Get-BicepChildResourceType -ResourceProvider Microsoft.Web -Resource slots -Child scans/scanRes -ExactMatch |
            Should -BeNullOrEmpty
    }
}

Describe 'Bicep resource type discovery' {
    It 'returns resources and children when optional filters are omitted' {
        @(Get-BicepResourceType).Count | Should -BeGreaterThan 0
        @(Get-BicepChildResourceType).Count | Should -BeGreaterThan 0
        @(Get-BicepResourceType Microsoft.Storage -ExactMatch).Count | Should -BeGreaterThan 0
        @(Get-BicepChildResourceType Microsoft.Web sites -ExactMatch).Count | Should -BeGreaterThan 0
    }

    It 'completes resources without a bound provider' {
        $completer = [PSBicep.Completers.BicepResourceCompleter]::new()
        $results = @($completer.CompleteArgument('', '', 'storageAccounts', $null, @{}))

        $results.Count | Should -BeGreaterThan 0
        $results.CompletionText | Should -Contain 'storageAccounts'
    }

    It 'accepts fully qualified child types deeper than three segments' {
        $result = @(Get-BicepChildResourceType -FullyQualifiedName Microsoft.Web/sites/slots/functions -ExactMatch)

        $result | Should -Be @('slots/functions')
    }

    It 'returns short and fully qualified resource type names' {
        Get-BicepResourceType Microsoft.Storage storageAccounts -ExactMatch |
            Should -BeExactly 'storageAccounts'
        Get-BicepResourceType Microsoft.Storage storageAccounts -ExactMatch -OutputFullyQualifiedName |
            Should -BeExactly 'Microsoft.Storage/storageAccounts'
    }

    It 'returns providers in deterministic case-insensitive order' {
        $actual = @(Get-BicepResourceProvider)
        $expected = [string[]]$actual.Clone()
        [Array]::Sort($expected, [StringComparer]::OrdinalIgnoreCase)

        $actual -join "`n" | Should -BeExactly ($expected -join "`n")
    }

    It 'enumerates API versions for every piped resource type' {
        $types = @('Microsoft.Storage/storageAccounts', 'Microsoft.Web/sites')
        $expected = @($types | ForEach-Object { Get-BicepApiVersion -ResourceType $_ })
        $actual = @($types | Get-BicepApiVersion)

        $actual -join "`n" | Should -BeExactly ($expected -join "`n")
    }
}
