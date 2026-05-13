---
document type: cmdlet
external help file: Bicep-help.xml
HelpUri: ''
Locale: en-US
Module Name: Bicep
ms.date: 05/13/2026
PlatyPS schema version: 2024-05-01
title: Disconnect-Bicep
---

# Disconnect-Bicep

## SYNOPSIS

Clears the current Azure authentication session for Bicep operations.

## SYNTAX

### __AllParameterSets

```
Disconnect-Bicep [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  None


## DESCRIPTION

Resets the module-scoped authentication variables, effectively disconnecting the current Azure session. This clears stored tokens, certificate paths, and token splat parameters so subsequent Bicep commands will require re-authentication.

## EXAMPLES

### Example 1

Disconnect from the current Azure session.

## PARAMETERS

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Object

Returns $true if the disconnection was successful, $false otherwise.

## NOTES

This command clears all Azure authentication context stored by the Bicep module. After running this command, you must call Connect-Bicep again before using any commands that require Azure authentication.

## RELATED LINKS

- [Connect-Bicep]()
- [Azure Authentication](https://learn.microsoft.com/azure/azure-resource-manager/authenticate-powershell)
