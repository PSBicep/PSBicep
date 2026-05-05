---
document type: cmdlet
external help file: Bicep-help.xml
HelpUri: ''
Locale: en-US
Module Name: Bicep
ms.date: 05/08/2026
PlatyPS schema version: 2024-05-01
title: New-BicepParameterFile
---

# New-BicepParameterFile

## SYNOPSIS

Creates an ARM Template parameter file based on a bicep file.

## SYNTAX

### __AllParameterSets

```
New-BicepParameterFile [-Path] <string> [[-Parameters] <string>] [[-OutputDirectory] <string>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  None


## DESCRIPTION

Creates an ARM Template parameter file based on a bicep file.
The parameter file can be used during deployment with Azure CLI or Azure PowerShell.

## EXAMPLES

### Generate an ARM Template parameter file for a bicep file

New-BicepParameterFile -Path 'AzureFirewall.bicep'

Creates a parameter file called AzureFirewall.parameters.json in the same directory as the bicep file.

### Generate an ARM Template parameter file for a bicep file with all parameters from the bicep file

New-BicepParameterFile -Path 'AzureFirewall.bicep' -Parameters All

Creates a parameter file called AzureFirewall.parameters.json in the same directory as the bicep file.

### Creates a parameter file in the specified directory

New-BicepParameterFile -Path 'AzureFirewall.bicep' -OutputDirectory 'd:\myfolder\'

Creates a parameter file in the specified directory.

## PARAMETERS

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

### -OutputDirectory

Specifies the directory where the parameter file should be stored.

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 3
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Parameters

Specify which parameters should be exported to the parameter file.

```yaml
Type: System.String
DefaultValue: None
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

Path to the bicep file which the parameter file should be created from.

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

### -WhatIf

Shows what would happen if the cmdlet runs.
The cmdlet is not run.

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

## OUTPUTS

### System.Object

Returns the path to the created parameter file.

## NOTES

## RELATED LINKS

- [Update-BicepParameterFile]()
- [Build-Bicep]()
