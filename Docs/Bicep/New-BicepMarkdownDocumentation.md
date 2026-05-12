---
document type: cmdlet
external help file: Bicep-help.xml
HelpUri: ''
Locale: en-US
Module Name: Bicep
ms.date: 05-11-2026
PlatyPS schema version: 2024-05-01
title: New-BicepMarkdownDocumentation
---

# New-BicepMarkdownDocumentation

## SYNOPSIS

Create markdown documentation for bicep files

## SYNTAX

### FromFile (Default)

```
New-BicepMarkdownDocumentation [[-File] <string>] [-AsString] [-Force] [<CommonParameters>]
```

### FromFolder

```
New-BicepMarkdownDocumentation [[-Path] <string>] [-Recurse] [-AsString] [-Force]
 [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  None


## DESCRIPTION

This command creates a basic markdown documentation of one or more bicep files.

## EXAMPLES

### Example 1

PS C:\> New-BicepMarkdownDocumentation -File C:\MyBicepFile.bicep

This command will create a file called `c:\MyBicepFile.md` containing basic documentation.

### Example 2

PS C:\> New-BicepMarkdownDocumentation -Path C:\MyBicepFiles\ -Verbose -Recurse

This command will traverse the c:\MyBicepFiles\ folder, including subfolders, and create documentation for all bicep files.
The markdown files will be saved with the same name as the bicep files, using .md file extension.

## PARAMETERS

### -AsString

Output the resulting markdown to to the console as string.

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
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Force

NOT IMPLEMENTED!

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
  IsRequired: false
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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### File or string

Returns the path to the created markdown file, or a string containing the markdown content if -AsString is used.

### System.Object

Generates markdown documentation from .bicep files, including metadata, providers, resources, outputs, parameters, and variables sections based on the compiled Bicep template.

## NOTES

## RELATED LINKS

- [Build-Bicep]()
- [New-BicepParameterFile]()
