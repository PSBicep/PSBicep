---
document type: cmdlet
external help file: Bicep-help.xml
HelpUri: ''
Locale: en-US
Module Name: Bicep
ms.date: 05/13/2026
PlatyPS schema version: 2024-05-01
title: New-BicepMarkdownDocumentation
---

# New-BicepMarkdownDocumentation

## SYNOPSIS

Create markdown documentation for bicep files

## SYNTAX

### FromFile (Default)

```
New-BicepMarkdownDocumentation [-File] <string> [-OutputPath <string>] [-OutputDirectory <string>]
 [-TemplateFile <string>] [-TemplateRoot <string>] [-CustomValue <hashtable>]
 [-CustomValueFilePath <string[]>] [-NoRestore] [-AsString] [-Force] [<CommonParameters>]
```

### FromFolder

```
New-BicepMarkdownDocumentation [-Path] <string> [-Recurse] [-OutputDirectory <string>]
 [-TemplateFile <string>] [-TemplateRoot <string>] [-CustomValue <hashtable>]
 [-CustomValueFilePath <string[]>] [-NoRestore] [-AsString] [-Force] [<CommonParameters>]
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

PS C:\> New-BicepMarkdownDocumentation -File C:\MyBicepFile.bicep

This command will create a file called `C:\README.md` containing documentation for the module.

### Example 2

PS C:\> New-BicepMarkdownDocumentation -Path C:\MyBicepFiles\ -Recurse -OutputDirectory C:\Docs

This command will traverse the C:\MyBicepFiles\ folder, including subfolders, and create
documentation for all bicep files under C:\Docs, preserving the folder structure.

### Example 3

PS C:\> New-BicepMarkdownDocumentation -File C:\MyBicepFile.bicep -TemplateFile C:\Templates\docs.scriban -CustomValue @{ env = 'prod' }

This command renders the documentation using a custom Scriban template with the custom value
`env` available to the template.

## PARAMETERS

### -AsString

Output the resulting markdown to the console as string instead of writing a file. Cannot be
combined with -OutputPath, -OutputDirectory or -Force.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: FromFolder
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: FromFile
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
- Name: FromFolder
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: FromFile
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
- Name: FromFolder
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: FromFile
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -File

Bicep file to create documentation from

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: FromFile
  Position: 0
  IsRequired: true
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
- Name: FromFolder
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: FromFile
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
- Name: FromFolder
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: FromFile
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

Directory to write the generated documentation to. In folder mode, the source folder structure
relative to -Path is preserved beneath this directory. Directories are created as needed.

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: FromFolder
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: FromFile
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -OutputPath

Exact path of the generated documentation file. Only available when documenting a single file.

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: FromFile
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Path

Path to folder containing bicep files.
All files in folder will have markdown documentation created.

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: FromFolder
  Position: 0
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Recurse

Search recursively for .bicep files.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: FromFolder
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
- Name: FromFolder
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: FromFile
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
- Name: FromFolder
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: FromFile
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

## OUTPUTS

### System.IO.FileInfo

Returns the created markdown file, or a string containing the markdown content if -AsString is
used.

### System.String

The rendered markdown content when -AsString is used.

## NOTES

The documentation generator is part of the Bicep `docs` feature which upstream Bicep labels as
experimental. A bicep file with compilation errors is refused and no documentation is generated
for it.

## RELATED LINKS

- [Build-Bicep]()
- [New-BicepParameterFile]()
