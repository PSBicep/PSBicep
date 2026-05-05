---
document type: cmdlet
external help file: Bicep-help.xml
HelpUri: ''
Locale: en-US
Module Name: Bicep
ms.date: 05/08/2026
PlatyPS schema version: 2024-05-01
title: Install-BicepCLI
---

# Install-BicepCLI

## SYNOPSIS

Install Bicep CLI (Windows only)

## SYNTAX

### __AllParameterSets

```
Install-BicepCLI [[-Version] <string>] [-Force] [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  None


## DESCRIPTION

Install-BicepCLI is a command to to install the Bicep CLI from the Azure/Bicep repo.

## EXAMPLES

### Install the latest Bicep CLI Version

Install-BicepCLI

### Install a specific Bicep CLI Version

Install-BicepCLI -Version '0.2.328'

## PARAMETERS

### -Force

This switch will force Bicep to be installed, even if another installation is already in place.

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

### -Version

This parameter specifies which version of Bicep CLI to install.

```yaml
Type: System.String
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 0
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

## NOTES

Go to module repository https://github.com/PSBicep/PSBicep for detailed info, reporting issues and to submit contributions.

## RELATED LINKS

- [Update-BicepCLI]()
- [Uninstall-BicepCLI]()
- [Get-BicepVersion]()
