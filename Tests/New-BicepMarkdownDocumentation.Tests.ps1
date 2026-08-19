# Data driven https://pester.dev/docs/usage/data-driven-tests
BeforeAll {
    Import-Module -FullyQualifiedName "$PSScriptRoot\..\output\module\Bicep" -ErrorAction Stop
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
    },
    @{
        name     = 'languageVersion2.bicep'
        fullName = "$PSScriptRoot\supportFiles\languageVersion2.bicep"
    }
) {

    BeforeAll {
        # Don't need to exec it multiple times, just once
        $result = New-BicepMarkdownDocumentation -File $_.FullName -AsString

        # Calm down PSScriptAnalyzer as it is used.
        $null = $result
    }

    It '<name> should return a string with the sections the native template always emits' {
        $result | Should -Match '## Navigation'
        $result | Should -Match '## Resource Types'
        $result | Should -Match '## Parameters'
        $result | Should -Match '## Outputs'
    }

    It '<name> should start with a level one heading' {
        $result | Should -Match '^# '
    }

    It '<name> should return a valid markdown string' {
        $result | ConvertFrom-Markdown | Should -Not -BeNullOrEmpty
    }

    It '<name> should produce deterministic output' {
        $secondResult = New-BicepMarkdownDocumentation -File $_.FullName -AsString
        $secondResult | Should -BeExactly $result
    }

    It '<name> should use LF line endings and end with exactly one trailing newline' {
        $result | Should -Not -Match "`r"
        $result | Should -Match "[^`n]`n$"
    }

    It '<name> contains the expected module documentation' {
        switch ($_.name) {
            'workingBicep.bicep' {
                $result | Should -Match 'Microsoft\.Storage/storageAccounts'
                $result | Should -Match '### `location`'
                $result | Should -Match '### `name`'
                $result | Should -Match 'resourceId'
            }
            'main.bicep' {
                $result | Should -Match '## Cross-referenced Modules'
                $result | Should -Match 'workingBicep\.bicep'
            }
            'bicepWithMeta.bicep' {
                $result | Should -Match '_No resources are declared in this module\._'
                $result | Should -Match '_No parameters are declared in this module\._'
                $result | Should -Match '_No outputs are declared in this module\._'
            }
            default {
                $true | Should -BeTrue
            }
        }
    }
}

Describe 'New-BicepMarkdownDocumentation file output' {

    BeforeEach {
        $ModuleFolder = New-Item -Path (Join-Path $TestDrive 'module') -ItemType Directory -Force
        Copy-Item -Path "$PSScriptRoot\supportFiles\workingBicep.bicep" -Destination $ModuleFolder.FullName
        $SourceFile = Join-Path $ModuleFolder.FullName 'workingBicep.bicep'
    }

    AfterEach {
        Remove-Item -Path (Join-Path $TestDrive 'module') -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path (Join-Path $TestDrive 'out') -Recurse -Force -ErrorAction SilentlyContinue
    }

    It 'writes README.md next to the source file by default' {
        $OutputFile = New-BicepMarkdownDocumentation -File $SourceFile
        $OutputFile.Name | Should -Be 'README.md'
        $OutputFile.DirectoryName | Should -Be $ModuleFolder.FullName
        Get-Content -Path $OutputFile.FullName -Raw | Should -Match '## Parameters'
    }

    It 'does not overwrite an existing output file without -Force' {
        $null = New-BicepMarkdownDocumentation -File $SourceFile
        { New-BicepMarkdownDocumentation -File $SourceFile -ErrorAction Stop } | Should -Throw -ExpectedMessage '*already exists*'
    }

    It 'overwrites an existing output file with -Force' {
        $null = New-BicepMarkdownDocumentation -File $SourceFile
        $OutputFile = New-BicepMarkdownDocumentation -File $SourceFile -Force
        $OutputFile.Name | Should -Be 'README.md'
    }

    It 'writes to the exact path given by -OutputPath' {
        $TargetPath = Join-Path $TestDrive 'out\workingBicep.md'
        $null = New-Item -Path (Join-Path $TestDrive 'out') -ItemType Directory -Force
        $OutputFile = New-BicepMarkdownDocumentation -File $SourceFile -OutputPath $TargetPath
        $OutputFile.FullName | Should -Be $TargetPath
    }

    It 'writes README.md under -OutputDirectory' {
        $TargetDirectory = Join-Path $TestDrive 'out'
        $OutputFile = New-BicepMarkdownDocumentation -File $SourceFile -OutputDirectory $TargetDirectory
        $OutputFile.FullName | Should -Be (Join-Path $TargetDirectory 'README.md')
    }

    It 'preserves the folder structure under -OutputDirectory in folder mode' {
        $NestedFolder = New-Item -Path (Join-Path $ModuleFolder.FullName 'nested') -ItemType Directory -Force
        Copy-Item -Path "$PSScriptRoot\supportFiles\workingBicep.bicep" -Destination $NestedFolder.FullName
        $TargetDirectory = Join-Path $TestDrive 'out'
        $OutputFiles = New-BicepMarkdownDocumentation -Path $ModuleFolder.FullName -Recurse -OutputDirectory $TargetDirectory
        $OutputFiles.FullName | Should -Contain (Join-Path $TargetDirectory 'README.md')
        $OutputFiles.FullName | Should -Contain (Join-Path $TargetDirectory 'nested\README.md')
    }

    It 'reports a collision when two Bicep files in one folder resolve to the same output file' {
        Copy-Item -Path "$PSScriptRoot\supportFiles\bicepWithMeta.bicep" -Destination $ModuleFolder.FullName
        $Errors = @()
        $OutputFiles = New-BicepMarkdownDocumentation -Path $ModuleFolder.FullName -ErrorAction SilentlyContinue -ErrorVariable Errors
        $OutputFiles | Should -HaveCount 1
        $Errors.Count | Should -BeGreaterThan 0
        $Errors[0].ToString() | Should -Match 'already generated'
    }

    It 'continues past a broken Bicep file in folder mode when ErrorAction is Continue' {
        Copy-Item -Path "$PSScriptRoot\supportFiles\brokenBicep.bicep" -Destination $ModuleFolder.FullName
        $Errors = @()
        $OutputFiles = New-BicepMarkdownDocumentation -Path $ModuleFolder.FullName -ErrorAction SilentlyContinue -ErrorVariable Errors
        $OutputFiles | Should -HaveCount 1
        $Errors.Count | Should -BeGreaterThan 0
    }

    It 'throws when -AsString is combined with -OutputDirectory' {
        { New-BicepMarkdownDocumentation -File $SourceFile -AsString -OutputDirectory (Join-Path $TestDrive 'out') } |
            Should -Throw -ExpectedMessage '*cannot be combined*'
    }
}

Describe 'New-BicepMarkdownDocumentation custom templates' {

    BeforeAll {
        $SourceFile = "$PSScriptRoot\supportFiles\workingBicep.bicep"
        $TemplateFile = "$PSScriptRoot\supportFiles\customTemplate.scriban"
        $ValuesFile = "$PSScriptRoot\supportFiles\customValues.json"

        # Calm down PSScriptAnalyzer as they are used.
        $null = $SourceFile, $TemplateFile, $ValuesFile
    }

    It 'renders with a custom Scriban template and values from -CustomValueFilePath' {
        $result = New-BicepMarkdownDocumentation -File $SourceFile -TemplateFile $TemplateFile -CustomValueFilePath $ValuesFile -AsString
        $result | Should -Match 'Environment: dev'
        $result | Should -Match 'Owner: PSBicep'
    }

    It 'lets -CustomValue override values from -CustomValueFilePath' {
        $result = New-BicepMarkdownDocumentation -File $SourceFile -TemplateFile $TemplateFile -CustomValueFilePath $ValuesFile -CustomValue @{ env = 'prod' } -AsString
        $result | Should -Match 'Environment: prod'
        $result | Should -Match 'Owner: PSBicep'
    }

    It 'throws when a custom value file does not contain a JSON object' {
        $InvalidValuesFile = Join-Path $TestDrive 'invalidValues.json'
        Set-Content -Path $InvalidValuesFile -Value '["not", "an", "object"]'
        { New-BicepMarkdownDocumentation -File $SourceFile -CustomValueFilePath $InvalidValuesFile -AsString } |
            Should -Throw -ExpectedMessage '*must contain a JSON object*'
    }
}

Describe 'New-BicepMarkdownDocumentation on a broken Bicep file' {
    It 'throws when the Bicep file has compilation errors and ErrorAction is Stop' {
        { New-BicepMarkdownDocumentation -File "$PSScriptRoot\supportFiles\brokenBicep.bicep" -AsString -ErrorAction Stop } | Should -Throw
    }
}
