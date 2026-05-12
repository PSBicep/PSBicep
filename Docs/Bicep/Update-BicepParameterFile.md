---
document type: cmdlet
external help file: Bicep-help.xml
HelpUri: ''
Locale: en-US
Module Name: Bicep
ms.date: 05-11-2026
PlatyPS schema version: 2024-05-01
title: Update-BicepParameterFile
---

# Update-BicepParameterFile

## SYNOPSIS

Updates existing ARM Template parameter file based on a bicep file.

## SYNTAX

### __AllParameterSets

```
Update-BicepParameterFile [-Path] <string> [[-BicepFile] <string>] [[-Parameters] <string>]
 [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  None


## DESCRIPTION

Updates a parameter file with new parameters, without removing existing values.
Also removes parameters from the parameter file if they have been removed from the bicep file.

## EXAMPLES

### Example 1

PS C:\> Update-BicepParameterFile -Path .\vnet.parameters.json

Update a parameter file vnet.parameters.json, without specifying the name of the bicep file.
It will look for a bicep file in the same directory with a name based on the parameterfile.
In this case vnet.bicep.

### Example 2

PS C:\> Update-BicepParameterFile -Path .\vnet.parameters.json -BicepFile .\bicepfiles\virtualnetwork.bicep

Update a parameter file vnet.parameters.json, specifying the location of the bicep file.

## PARAMETERS

### -BicepFile

Path to the bicep file which the parameter file should be updated from.

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

### -Parameters

Whether or not to update the parameter file with all parameters or only the required ones.

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

### -Path

Path to the parameters.json file that needs updating.

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

Returns the path to the updated parameter file.

## NOTES

## RELATED LINKS

- [New-BicepParameterFile]()
- [Build-Bicep]()
