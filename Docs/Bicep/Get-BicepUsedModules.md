---
document type: cmdlet
external help file: Bicep-help.xml
HelpUri: ''
Locale: en-US
Module Name: Bicep
ms.date: 05-11-2026
PlatyPS schema version: 2024-05-01
title: Get-BicepUsedModules
---

# Get-BicepUsedModules

## SYNOPSIS

Get modules used in a Bicep file.

## SYNTAX

### __AllParameterSets

```
Get-BicepUsedModules [-Path] <string[]> [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  None


## DESCRIPTION

Get information about modules used in a Bicep file.

## EXAMPLES

### Example 1

PS C:\> Get-BicepUsedModules -Path $BicepFilePath

Get all modules from a specific Bicep file.

## PARAMETERS

### -Path

The path to the Bicep file.

```yaml
Type: System.String[]
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 0
  IsRequired: true
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

### System.Object

An array of objects, each containing:
- **Name**: The identifier of the module declaration.
- **Path**: The path or URI of the module.

## NOTES

## RELATED LINKS

- [Find-BicepModule]()
- [Restore-Bicep]()
- [Build-Bicep]()
- [ConvertTo-Bicep]()
