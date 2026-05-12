---
document type: cmdlet
external help file: Bicep-help.xml
HelpUri: ''
Locale: en-US
Module Name: Bicep
ms.date: 05-11-2026
PlatyPS schema version: 2024-05-01
title: Restore-Bicep
---

# Restore-Bicep

## SYNOPSIS

Restores external modules from the specified Bicep file to the local module cache.

## SYNTAX

### __AllParameterSets

```
Restore-Bicep [-Path] <string> [-Force] [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  None


## DESCRIPTION

Restores all external modules referenced in the .bicep file to the local module cache.
Modules from an ACR bicep registry is stored under '%USERPROFILE%\.bicep\br' and template spec modules '%USERPROFILE%\.bicep\ts'.

## EXAMPLES

### Example 1

Restore-Bicep -Path .\main.bicep

Restores all external modules used in main.bicep to the local module cache.

## PARAMETERS

### -Force

Overwrites any existing files in the local module cache.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 2
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Path

Bicep file to restore.

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 1
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

Returns the path to the restored modules.

## NOTES

## RELATED LINKS

- [Build-Bicep]()
- [Clear-BicepModuleCache]()
