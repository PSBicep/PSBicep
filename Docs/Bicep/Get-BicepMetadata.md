---
document type: cmdlet
external help file: Bicep-help.xml
HelpUri: ''
Locale: en-US
Module Name: Bicep
ms.date: 05/13/2026
PlatyPS schema version: 2024-05-01
title: Get-BicepMetadata
---

# Get-BicepMetadata

## SYNOPSIS

Get metadata from a Bicep template

## SYNTAX

### __AllParameterSets

```
Get-BicepMetadata [-Path] <string> [[-OutputType] <string>] [-IncludeReservedMetadata]
 [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  None


## DESCRIPTION

Get metadata from a Bicep template

## EXAMPLES

### Example 1 - Get metadata from Bicep file

Get-BicepMetadata -Path .\myTemplate.bicep

Get metadata from Bicep file

### Example 2 - Get metadata from Bicep file and output as Json

Get-BicepMetadata -Path .\myTemplate.bicep -OutputType Json

Get metadata from Bicep file and output as json

### Example 3 - Get metadata from Bicep file and output as hashtable

Get-BicepMetadata -Path .\myTemplate.bicep -OutputType Hashtable

Get metadata from Bicep file and output as hashtable

### Example 4 - Get metadata from Bicep file and include reserved metadata

Get-BicepMetadata -Path .\myTemplate.bicep -IncludeReservedMetadata

Get metadata from Bicep file and include Bicep reserved metadata

## PARAMETERS

### -IncludeReservedMetadata

Include Bicep reserved metadata

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

### -OutputType

Specify output type

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 1
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Path

Path to Bicep file

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases:
- PSPath
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

Returns the metadata from the Bicep template's compiled ARM template output. The type depends on the `-OutputType` parameter: a PSObject (default), a JSON string, or a Hashtable.

## NOTES

## RELATED LINKS

- [Build-Bicep]()
- [Build-BicepParam]()
- [Get-BicepConfig]()
