---
document type: cmdlet
external help file: Bicep-help.xml
HelpUri: ''
Locale: en-US
Module Name: Bicep
ms.date: 05/13/2026
PlatyPS schema version: 2024-05-01
title: Get-BicepVersion
---

# Get-BicepVersion

## SYNOPSIS

View the installed version and the latest available version of Bicep CLI.

## SYNTAX

### __AllParameterSets

```
Get-BicepVersion [-All]
```

## ALIASES

This cmdlet has the following aliases,
  None


## DESCRIPTION

Get-BicepVersion is a command to compare the installed version of Bicep CLI with the latest release available in the Azure/Bicep repo.

## EXAMPLES

### Compare installed version with latest release

Get-BicepVersion

## PARAMETERS

### -All

Gets all available Bicep versions.

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

## INPUTS

## OUTPUTS

### System.Object

Outputs object with information about BicepVersions installed and available online-

## NOTES

Go to module repository https://github.com/PSBicep/PSBicep for detailed info, reporting issues and to submit contributions.

## RELATED LINKS

- [Get-Help about_Bicep_Help]()
- [Online Version](https://github.com/PSBicep/PSBicep)
