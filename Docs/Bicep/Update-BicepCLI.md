---
document type: cmdlet
external help file: Bicep-help.xml
HelpUri: ''
Locale: en-US
Module Name: Bicep
ms.date: 05-11-2026
PlatyPS schema version: 2024-05-01
title: Update-BicepCLI
---

# Update-BicepCLI

## SYNOPSIS

Update Bicep CLI (Windows only)

## SYNTAX

### __AllParameterSets

```
Update-BicepCLI [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  None


## DESCRIPTION

Update-BicepCLI is a command to update to the latest Bicep CLI release available from the Azure/Bicep repo.

## EXAMPLES

### Example 1

Update-BicepCLI

## PARAMETERS

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Object

Updates the Bicep CLI to the latest version by uninstalling the current version and installing the newest release. Outputs status messages indicating the update progress and installed version.

## NOTES

Go to module repository <https://github.com/PSBicep/PSBicep> for detailed info, reporting issues and to submit contributions.

## RELATED LINKS

- [Install-BicepCLI]()
- [Uninstall-BicepCLI]()
- [Get-BicepVersion]()
