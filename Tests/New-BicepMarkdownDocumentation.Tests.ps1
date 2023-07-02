# Data driven https://pester.dev/docs/usage/data-driven-tests
BeforeAll {
    Import-Module -FullyQualifiedName "$PSScriptRoot\..\Source\Bicep.psd1" -ErrorAction Stop -Force
}


Describe 'New-BicepMarkdownDocumentation' -ForEach @(
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

    BeforeAll {
        # Don't need to exec it multiple times, just once
        $result = New-BicepMarkdownDocumentation -File $_.FullName -Console

        # Calm down PSScriptAnalyzer as it is used.
        $null = $result
    }

    It '<name> should return a string with Providers, Resources, Parameters, Variables and Outputs headers' {
        $result | Should -Match '## Metadata'
        $result | Should -Match '## Providers'
        $result | Should -Match '## Resources'      
        $result | Should -Match '## Parameters'
        $result | Should -Match '## Variables'
        $result | Should -Match '## Outputs'
    }

    It '<name> should return a valid markdown string' {
        $result | ConvertFrom-Markdown | Should -Not -BeNullOrEmpty
    }

    It '<name> contains the correct Metadata' {

        switch ($_.name) {
            'bicepWithMeta.bicep' {
                # Metadata array
                $result | Should -Match '| pesterMeta | author: PSBicep <br/> version: v1.0 <br/> aNumber: 1 |'
                # Metadata string
                $result | Should -Match '| someothervalue | something else |
                | value | something |'
            }
            'main.bicep' {
                # Just validating that the metadata is there, generator always changes due to hash
                $result | Should -Match '| _generator |'
            }
            'workingBicep.bicep' {
                $result | Should -Match '| _generator |'
            }
            default {
                throw "Unknown file name: $($_.name)"
            }
        }

    }

    It '<name> contains the correct Providers ' {

        switch ($_.name) {
            'bicepWithMeta.bicep' {
                $result | Should -Match  '## Providers\s+n\/a'
            }
            'main.bicep' {
                $result | Should -Match '\| Type \| Version \|\s+\|----\|----\|\s+\| Microsoft.Resources\/deployments'
            }
            'workingBicep.bicep' {
                $result | Should -Match '\| Type \| Version \|\s+\|----\|----\|\s+\| Microsoft.Storage\/storageAccounts'
            }
            default {
                throw "Unknown file name: $($_.name)"
            }
        }

    }

    It '<name> contains the correct Resources' {

        switch ($_.name) {
            'bicepWithMeta.bicep' {
                $result | Should -Match '## Resources\s+n\/a'
            }
            'main.bicep' {
                $result | Should -Match "\| Name \| Link \| Location \|\s+\|----\|----\|----\|\s+\| storageDeploy \| \[Microsoft\.Resources\/deployments"
            }
            'workingBicep.bicep' {
                $result | Should -Match "\| Name \| Link \| Location \|\s+\|----\|----\|----\|\s+\| \[variables\('nameVariable'\)\] \| \[Microsoft\.Storage\/storageAccounts"
            }
            default {
                throw "Unknown file name: $($_.name)"
            }
        }

    }
    It '<name> contains the correct Parameters' {

        switch ($_.name) {
            'bicepWithMeta.bicep' {
                $result | Should -Match '## Parameters\s+n\/a'
            }
            'main.bicep' {
                $result | Should -Match '| Name | Type | AllowedValues | Metadata |\s+|----|----|----|----|\s+\| location | string | n/a |  |'
            }
            'workingBicep.bicep' {
                $result | Should -Match '\| Name \| Type \| AllowedValues \| Metadata \|\s+\|----\|----\|----\|----\|\s+\| location \| string \| n\/a \|  \|\s+\| name \| string \| n\/a \|  \|'
            }
            default {
                throw "Unknown file name: $($_.name)"
            }
        }

    }
    It '<name> contains the correct Variables' {

        switch ($_.name) {
            'bicepWithMeta.bicep' {
                $result | Should -Match '## Variables\s+n\/a'
            }
            'main.bicep' {
                $result | Should -Match '## Variables\s+n\/a'
            }
            'workingBicep.bicep' {
                $regexStr = '| nameVariable | [format(''{0}storageaccount'', parameters(''name''))] |'
                $escapedRegexStr = [Regex]::Escape($regexStr)
                $result | Should -Match $escapedRegexStr
            }
            default {
                throw "Unknown file name: $($_.name)"
            }
        }

    }
    It '<name> contains the correct Outputs' {

        switch ($_.name) {
            'bicepWithMeta.bicep' {
                $result | Should -Match '## Outputs\s+n\/a'
            }
            'main.bicep' {
                $result | Should -Match '## Outputs\s+n\/a'
            }
            'workingBicep.bicep' {
                $result | Should -Match ''
            }
            default {
                throw "Unknown file name: $($_.name)"
            }
        }

    }

    It '<name> contains the correct Modules' {
            
            switch ($_.name) {
                'bicepWithMeta.bicep' {
                    $result | Should -Match '## Modules\s+n\/a'
                }
                'main.bicep' {
                    $regexStr = '| storage | workingBicep.bicep |'
                    $escapedRegexStr = [Regex]::Escape($regexStr)
                    $result | Should -Match $escapedRegexStr
                }
                'workingBicep.bicep' {
                    $result | Should -Match '## Modules\s+n\/a'
                }
                default {
                    throw "Unknown file name: $($_.name)"
                }
            }
    
    }

}

Describe 'New-BicepMarkdownDocumentation' -ForEach @(
    @{
        name     = 'brokenBicep.bicep'
        fullName = "$PSScriptRoot\supportFiles\brokenBicep.bicep"
    }
) {

    It "<name> should throw an error" {
        { New-BicepMarkdownDocumentation -File $_.FullName -Console } | Should -Throw
    }
}
