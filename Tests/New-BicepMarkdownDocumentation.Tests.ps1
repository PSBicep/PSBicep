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
        $result = New-BicepMarkdownDocumentation -Path $_.FullName -AsString

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
        $secondResult = New-BicepMarkdownDocumentation -Path $_.FullName -AsString
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
                # Parameters are listed in a table; a parameter only gets its own heading when it has details such as a default value
                $result | Should -Match '\| `location` \| `string` \| No \|'
                $result | Should -Match '\| `name` \| `string` \| Yes \|'
                $result | Should -Match '### `location`'
                $result | Should -Match 'Default value: `resourceGroup\(\)\.location`'
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
        $OutputFile = New-BicepMarkdownDocumentation -Path $SourceFile
        $OutputFile.Name | Should -Be 'README.md'
        $OutputFile.DirectoryName | Should -Be $ModuleFolder.FullName
        Get-Content -Path $OutputFile.FullName -Raw | Should -Match '## Parameters'
    }

    It 'does not overwrite an existing output file without -Force' {
        $null = New-BicepMarkdownDocumentation -Path $SourceFile
        { New-BicepMarkdownDocumentation -Path $SourceFile -ErrorAction Stop } | Should -Throw -ExpectedMessage '*already exists*'
    }

    It 'overwrites an existing output file with -Force' {
        $null = New-BicepMarkdownDocumentation -Path $SourceFile
        $OutputFile = New-BicepMarkdownDocumentation -Path $SourceFile -Force
        $OutputFile.Name | Should -Be 'README.md'
    }

    It 'writes nothing with -WhatIf' {
        $OutputFile = New-BicepMarkdownDocumentation -Path $SourceFile -WhatIf
        $OutputFile | Should -BeNullOrEmpty
        Test-Path -Path (Join-Path $ModuleFolder.FullName 'README.md') | Should -BeFalse
    }

    It 'writes to the exact path given by -OutputPath' {
        $TargetPath = Join-Path $TestDrive 'out\workingBicep.md'
        $null = New-Item -Path (Join-Path $TestDrive 'out') -ItemType Directory -Force
        $OutputFile = New-BicepMarkdownDocumentation -Path $SourceFile -OutputPath $TargetPath
        $OutputFile.FullName | Should -Be $TargetPath
    }

    It 'writes README.md under -OutputDirectory' {
        $TargetDirectory = Join-Path $TestDrive 'out'
        $OutputFile = New-BicepMarkdownDocumentation -Path $SourceFile -OutputDirectory $TargetDirectory
        $OutputFile.FullName | Should -Be (Join-Path $TargetDirectory 'README.md')
    }

    It 'preserves the folder structure under -OutputDirectory when -Path is a folder' {
        $NestedFolder = New-Item -Path (Join-Path $ModuleFolder.FullName 'nested') -ItemType Directory -Force
        Copy-Item -Path "$PSScriptRoot\supportFiles\workingBicep.bicep" -Destination $NestedFolder.FullName
        $TargetDirectory = Join-Path $TestDrive 'out'
        $OutputFiles = New-BicepMarkdownDocumentation -Path $ModuleFolder.FullName -Recurse -OutputDirectory $TargetDirectory
        $OutputFiles.FullName | Should -Contain (Join-Path $TargetDirectory 'README.md')
        $OutputFiles.FullName | Should -Contain (Join-Path $TargetDirectory 'nested\README.md')
    }

    It 'does not nest a single file below -OutputDirectory' {
        $NestedFolder = New-Item -Path (Join-Path $ModuleFolder.FullName 'nested') -ItemType Directory -Force
        Copy-Item -Path "$PSScriptRoot\supportFiles\workingBicep.bicep" -Destination $NestedFolder.FullName
        $TargetDirectory = Join-Path $TestDrive 'out'
        $OutputFile = New-BicepMarkdownDocumentation -Path (Join-Path $NestedFolder.FullName 'workingBicep.bicep') -OutputDirectory $TargetDirectory
        $OutputFile.FullName | Should -Be (Join-Path $TargetDirectory 'README.md')
    }

    It 'reports a collision when two bicep files in one folder resolve to the same output file' {
        Copy-Item -Path "$PSScriptRoot\supportFiles\bicepWithMeta.bicep" -Destination $ModuleFolder.FullName
        $Errors = @()
        $OutputFiles = New-BicepMarkdownDocumentation -Path $ModuleFolder.FullName -ErrorAction SilentlyContinue -ErrorVariable Errors
        $OutputFiles | Should -HaveCount 1
        $Errors.Count | Should -BeGreaterThan 0
        $Errors[0].ToString() | Should -Match 'already generated'
    }

    It 'reports an error when -OutputPath is used with more than one bicep file' {
        Copy-Item -Path "$PSScriptRoot\supportFiles\bicepWithMeta.bicep" -Destination $ModuleFolder.FullName
        $Errors = @()
        $TargetPath = Join-Path $TestDrive 'out\combined.md'
        $OutputFiles = New-BicepMarkdownDocumentation -Path $ModuleFolder.FullName -OutputPath $TargetPath -ErrorAction SilentlyContinue -ErrorVariable Errors
        $OutputFiles | Should -HaveCount 1
        $Errors[0].ToString() | Should -Match 'single bicep file'
    }

    It 'continues past a broken bicep file in folder mode when ErrorAction is Continue' {
        Copy-Item -Path "$PSScriptRoot\supportFiles\brokenBicep.bicep" -Destination $ModuleFolder.FullName
        $Errors = @()
        $OutputFiles = New-BicepMarkdownDocumentation -Path $ModuleFolder.FullName -ErrorAction SilentlyContinue -ErrorVariable Errors
        $OutputFiles | Should -HaveCount 1
        $Errors.Count | Should -BeGreaterThan 0
    }

    It 'cannot resolve a parameter set when -AsString is combined with -OutputDirectory' {
        { New-BicepMarkdownDocumentation -Path $SourceFile -AsString -OutputDirectory (Join-Path $TestDrive 'out') } |
            Should -Throw -ErrorId 'AmbiguousParameterSet,New-BicepMarkdownDocumentation'
    }

    It 'cannot resolve a parameter set when -OutputPath is combined with -OutputDirectory' {
        { New-BicepMarkdownDocumentation -Path $SourceFile -OutputPath (Join-Path $TestDrive 'out\a.md') -OutputDirectory (Join-Path $TestDrive 'out') } |
            Should -Throw -ErrorId 'AmbiguousParameterSet,New-BicepMarkdownDocumentation'
    }
}

Describe 'New-BicepMarkdownDocumentation path handling' {

    BeforeEach {
        $ModuleFolder = New-Item -Path (Join-Path $TestDrive 'module') -ItemType Directory -Force
        Copy-Item -Path "$PSScriptRoot\supportFiles\workingBicep.bicep" -Destination $ModuleFolder.FullName
        Copy-Item -Path "$PSScriptRoot\supportFiles\bicepWithMeta.bicep" -Destination $ModuleFolder.FullName
        $NestedFolder = New-Item -Path (Join-Path $ModuleFolder.FullName 'nested') -ItemType Directory -Force
        Copy-Item -Path "$PSScriptRoot\supportFiles\main.bicep" -Destination $NestedFolder.FullName
        Copy-Item -Path "$PSScriptRoot\supportFiles\workingBicep.bicep" -Destination $NestedFolder.FullName

        # Calm down PSScriptAnalyzer as they are used.
        $null = $ModuleFolder, $NestedFolder
    }

    AfterEach {
        Remove-Item -Path (Join-Path $TestDrive 'module') -Recurse -Force -ErrorAction SilentlyContinue
    }

    It 'takes a single file when -Path names a file' {
        $Result = New-BicepMarkdownDocumentation -Path (Join-Path $ModuleFolder.FullName 'workingBicep.bicep') -AsString
        $Result | Should -HaveCount 1
    }

    It 'takes every bicep file in the folder when -Path names a folder' {
        $Result = New-BicepMarkdownDocumentation -Path $ModuleFolder.FullName -AsString
        $Result | Should -HaveCount 2
    }

    It 'descends into subfolders with -Recurse' {
        $Result = New-BicepMarkdownDocumentation -Path $ModuleFolder.FullName -Recurse -AsString
        $Result | Should -HaveCount 4
    }

    It 'expands wildcards in -Path' {
        $Result = New-BicepMarkdownDocumentation -Path (Join-Path $ModuleFolder.FullName '*.bicep') -AsString
        $Result | Should -HaveCount 2
    }

    It 'ignores non-bicep files when -Path is a wildcard' {
        Set-Content -Path (Join-Path $ModuleFolder.FullName 'notes.txt') -Value 'not bicep'
        # '*' also matches the nested folder, which contributes its own two files. -ErrorAction Stop
        # proves notes.txt was skipped rather than handed to the documentation generator.
        $Result = New-BicepMarkdownDocumentation -Path (Join-Path $ModuleFolder.FullName '*') -AsString -ErrorAction Stop
        $Result | Should -HaveCount 4
    }

    It 'accepts several paths in one call' {
        $Paths = @(
            (Join-Path $ModuleFolder.FullName 'workingBicep.bicep')
            $NestedFolder.FullName
        )
        $Result = New-BicepMarkdownDocumentation -Path $Paths -AsString
        $Result | Should -HaveCount 3
    }

    It 'defaults to the current directory' {
        $Result = Invoke-Command -ScriptBlock {
            Push-Location -Path $ModuleFolder.FullName
            try { New-BicepMarkdownDocumentation -AsString }
            finally { Pop-Location }
        }
        $Result | Should -HaveCount 2
    }

    It 'writes an error for a path that does not exist' {
        $Errors = @()
        $null = New-BicepMarkdownDocumentation -Path (Join-Path $TestDrive 'doesNotExist') -AsString -ErrorAction SilentlyContinue -ErrorVariable Errors
        $Errors.Count | Should -BeGreaterThan 0
        $Errors[0].ToString() | Should -Match 'Failed to resolve path'
    }

    It 'warns when a folder contains no bicep files' {
        $EmptyFolder = New-Item -Path (Join-Path $TestDrive 'empty') -ItemType Directory -Force
        $Warnings = @()
        $null = New-BicepMarkdownDocumentation -Path $EmptyFolder.FullName -AsString -WarningVariable Warnings -WarningAction SilentlyContinue
        $Warnings.Count | Should -BeGreaterThan 0
    }
}

Describe 'New-BicepMarkdownDocumentation pipeline input' {

    BeforeEach {
        $ModuleFolder = New-Item -Path (Join-Path $TestDrive 'module') -ItemType Directory -Force
        Copy-Item -Path "$PSScriptRoot\supportFiles\workingBicep.bicep" -Destination $ModuleFolder.FullName
        Copy-Item -Path "$PSScriptRoot\supportFiles\bicepWithMeta.bicep" -Destination $ModuleFolder.FullName

        # Calm down PSScriptAnalyzer as it is used.
        $null = $ModuleFolder
    }

    AfterEach {
        Remove-Item -Path (Join-Path $TestDrive 'module') -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path (Join-Path $TestDrive 'out') -Recurse -Force -ErrorAction SilentlyContinue
    }

    It 'accepts FileInfo objects from Get-ChildItem' {
        $Result = Get-ChildItem -Path $ModuleFolder.FullName -Filter '*.bicep' | New-BicepMarkdownDocumentation -AsString
        $Result | Should -HaveCount 2
    }

    It 'accepts DirectoryInfo objects from Get-ChildItem' {
        $Result = Get-Item -Path $ModuleFolder.FullName | New-BicepMarkdownDocumentation -AsString
        $Result | Should -HaveCount 2
    }

    It 'accepts path strings' {
        $Result = (Get-ChildItem -Path $ModuleFolder.FullName -Filter '*.bicep').FullName | New-BicepMarkdownDocumentation -AsString
        $Result | Should -HaveCount 2
    }

    It 'detects output collisions across pipeline items' {
        $Errors = @()
        $OutputFiles = Get-ChildItem -Path $ModuleFolder.FullName -Filter '*.bicep' |
            New-BicepMarkdownDocumentation -ErrorAction SilentlyContinue -ErrorVariable Errors
        $OutputFiles | Should -HaveCount 1
        $Errors[0].ToString() | Should -Match 'already generated'
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
        $result = New-BicepMarkdownDocumentation -Path $SourceFile -TemplateFile $TemplateFile -CustomValueFilePath $ValuesFile -AsString
        $result | Should -Match 'Environment: dev'
        $result | Should -Match 'Owner: PSBicep'
    }

    It 'lets -CustomValue override values from -CustomValueFilePath' {
        $result = New-BicepMarkdownDocumentation -Path $SourceFile -TemplateFile $TemplateFile -CustomValueFilePath $ValuesFile -CustomValue @{ env = 'prod' } -AsString
        $result | Should -Match 'Environment: prod'
        $result | Should -Match 'Owner: PSBicep'
    }

    It 'throws when a custom value file does not contain a JSON object' {
        $InvalidValuesFile = Join-Path $TestDrive 'invalidValues.json'
        Set-Content -Path $InvalidValuesFile -Value '["not", "an", "object"]'
        { New-BicepMarkdownDocumentation -Path $SourceFile -CustomValueFilePath $InvalidValuesFile -AsString } |
            Should -Throw -ExpectedMessage '*must contain a JSON object*'
    }
}

Describe 'New-BicepMarkdownDocumentation on a broken bicep file' {
    It 'throws when the bicep file has compilation errors and ErrorAction is Stop' {
        { New-BicepMarkdownDocumentation -Path "$PSScriptRoot\supportFiles\brokenBicep.bicep" -AsString -ErrorAction Stop } | Should -Throw
    }
}
