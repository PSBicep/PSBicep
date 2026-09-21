---
document type: cmdlet
external help file: Bicep-help.xml
HelpUri: ''
Locale: en-US
Module Name: Bicep
ms.date: 09/16/2026
PlatyPS schema version: 2024-05-01
title: New-BicepMarkdownDocumentation
---

# New-BicepMarkdownDocumentation

## SYNOPSIS

Create markdown documentation for bicep files

## SYNTAX

### Default (Default)

```
New-BicepMarkdownDocumentation [[-Path] <string[]>] [-Recurse] [-TemplateFile <string>]
 [-TemplateRoot <string>] [-CustomValue <hashtable>] [-CustomValueFilePath <string[]>] [-NoRestore]
 [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### AsString

```
New-BicepMarkdownDocumentation [[-Path] <string[]>] -AsString [-Recurse] [-TemplateFile <string>]
 [-TemplateRoot <string>] [-CustomValue <hashtable>] [-CustomValueFilePath <string[]>] [-NoRestore]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

### OutputPath

```
New-BicepMarkdownDocumentation [[-Path] <string[]>] -OutputPath <string> [-Recurse]
 [-TemplateFile <string>] [-TemplateRoot <string>] [-CustomValue <hashtable>]
 [-CustomValueFilePath <string[]>] [-NoRestore] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### OutputDirectory

```
New-BicepMarkdownDocumentation [[-Path] <string[]>] -OutputDirectory <string> [-Recurse]
 [-TemplateFile <string>] [-TemplateRoot <string>] [-CustomValue <hashtable>]
 [-CustomValueFilePath <string[]>] [-NoRestore] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  None


## DESCRIPTION

This command creates markdown documentation for one or more bicep files using Bicep's native
documentation generator, the same engine used by the `bicep docs generate` CLI command.

The generated documentation includes the module's resource types, usage examples, parameters,
exported types, exported variables, exported functions, outputs and cross-referenced modules.
By default the documentation is written to a file named `README.md` next to each bicep file.
The output file name can be changed with the `documentation.output.file` setting in
`bicepconfig.json`, and the `documentation` configuration section also controls usage-example
discovery and baseline custom template values, exactly like the Bicep CLI.

The output can be customized with a Scriban template using `-TemplateFile` and `-TemplateRoot`,
and custom string values can be passed to the template with `-CustomValue` and
`-CustomValueFilePath`.

## EXAMPLES

### Example 1

PS C:\> New-BicepMarkdownDocumentation -Path C:\MyBicepFile.bicep

This command will create a file called `C:\README.md` containing documentation for the module.

### Example 2

PS C:\> New-BicepMarkdownDocumentation -Path C:\MyBicepFiles\ -Recurse -OutputDirectory C:\Docs

This command will traverse the C:\MyBicepFiles\ folder, including subfolders, and create
documentation for all bicep files under C:\Docs, preserving the folder structure.

### Example 3

PS C:\> Get-ChildItem C:\MyBicepFiles -Filter *.bicep -Recurse | New-BicepMarkdownDocumentation -Force

This command creates documentation next to every bicep file piped into it, overwriting any
existing output file.

### Example 4

PS C:\> New-BicepMarkdownDocumentation -Path C:\MyBicepFile.bicep -TemplateFile C:\Templates\docs.scriban -CustomValue @{ env = 'prod' }

This command renders the documentation using a custom Scriban template with the custom value
`env` available to the template.

## PARAMETERS

### -AsString

Output the resulting markdown to the console as string instead of writing a file.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: AsString
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Confirm

Prompts you for confirmation before running the cmdlet.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases:
- cf
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -CustomValue

Hashtable of custom string values exposed to the documentation template. Values given here
override values from -CustomValueFilePath and from the `documentation.template.values` setting
in `bicepconfig.json`.

```yaml
Type: System.Collections.Hashtable
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -CustomValueFilePath

One or more paths to JSON files containing objects of custom values exposed to the documentation
template. Files are applied in order, and -CustomValue overrides values from these files.

```yaml
Type: System.String[]
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Force

Overwrite the output file if it already exists. Without -Force, an existing output file is left
untouched and an error is written.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: OutputDirectory
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: OutputPath
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: Default
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -NoRestore

Skip restoring external modules referenced by the bicep file before compiling it.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -OutputDirectory

Directory to write the generated documentation to. When -Path resolves to a folder, the source
folder structure relative to that folder is preserved beneath this directory. Directories are
created as needed.

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: OutputDirectory
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -OutputPath

Exact path of the generated documentation file. Can only be used when -Path resolves to a single
bicep file.

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: OutputPath
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Path

Path to a bicep file or to a folder containing bicep files. A folder or a wildcard expands to the
`*.bicep` files it matches, while a path naming a single file is used as given. Accepts several
paths, and accepts file and folder paths from the pipeline. Defaults to the current directory.

```yaml
Type: System.String[]
DefaultValue: $pwd.Path
SupportsWildcards: true
Aliases:
- FullName
ParameterSets:
- Name: (All)
  Position: 0
  IsRequired: false
  ValueFromPipeline: true
  ValueFromPipelineByPropertyName: true
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Recurse

Search subfolders for .bicep files. Has no effect on a path that names a single file.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -TemplateFile

Path to a custom Scriban template used to render the documentation instead of the built-in
markdown template. Overrides the `documentation.template.file` setting in `bicepconfig.json`.

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -TemplateRoot

Root directory for Scriban template includes. Overrides the `documentation.template.includeRoot`
setting in `bicepconfig.json`. Defaults to the directory of the bicep file being documented.

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -WhatIf

Runs the command in a mode that only reports what would happen without performing the actions.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases:
- wi
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String[]

Paths to bicep files or to folders containing bicep files.

## OUTPUTS

### System.IO.FileInfo

Returns the created markdown file.

### System.String

The rendered markdown content when -AsString is used.

## NOTES

The documentation generator is part of the Bicep `docs` feature which upstream Bicep labels as
experimental. A bicep file with compilation errors is refused and no documentation is generated
for it.

## RELATED LINKS

- [Build-Bicep]()
- [New-BicepParameterFile]()
