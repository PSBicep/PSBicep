---
document type: cmdlet
external help file: Bicep-help.xml
HelpUri: ''
Locale: en-US
Module Name: Bicep
ms.date: 05/08/2026
PlatyPS schema version: 2024-05-01
title: Uninstall-BicepCLI
---

# Uninstall-BicepCLI

## SYNOPSIS

Uninstall Bicep CLI (Windows only)

## SYNTAX

### __AllParameterSets

```
Uninstall-BicepCLI [-Force] [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  None


## DESCRIPTION

Uninstall-BicepCLI uninstalls all Bicep CLI versions installed (Windows Installer and PowerShell installations)

## EXAMPLES

### Uninstall Bicep CLI

Uninstall-BicepCLI -Force

## PARAMETERS

### -Force

This switch will force Bicep to be uninstalled.

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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Object

No output is returned.

## NOTES

## RELATED LINKS

- [Install-BicepCLI]()
- [Update-BicepCLI]()
- [Get-BicepVersion]()
