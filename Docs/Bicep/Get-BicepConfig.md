---
document type: cmdlet
external help file: PSBicep.dll-Help.xml
HelpUri: ''
Locale: en-US
Module Name: Bicep
ms.date: 05-11-2026
PlatyPS schema version: 2024-05-01
title: Get-BicepConfig
---

# Get-BicepConfig

## SYNOPSIS

Get bicep configuration (bicepconfig.json) in use for a bicep file.

## SYNTAX

### Default (Default)

```
Get-BicepConfig [-Default] [-AsString] [<CommonParameters>]
```

### PathLocal

```
Get-BicepConfig -Path <string> -Local [-AsString] [<CommonParameters>]
```

### PathMerged

```
Get-BicepConfig -Path <string> -Merged [-AsString] [<CommonParameters>]
```

### PathOnly

```
Get-BicepConfig -Path <string> [-AsString] [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  None


## DESCRIPTION

Command to get the bicep configuration in use for a specific Bicep file.
Will return path to the bicepconfig.json file as well as the current settings.

## EXAMPLES

### Example 1 - Get bicep configuration for a bicep file

Get-BicepConfig -Path .\storage.bicep

### Example 2 - Get the merged bicep configuration for a bicep file

Get-BicepConfig -Path .\storage.bicep -Merged

Returns the path to the bicepconfig.json file in use, and the merged settings (default + local file).

### Example 3 - Get the local bicep configuration for a bicep file

Get-BicepConfig -Path .\storage.bicep -Merged

Returns the path to the bicepconfig.json file in use, and the settings in the local bicepconfig.json.

### Example 4 - Get the default bicep configuration

Get-BicepConfig -Default

Returns the default settings.

## PARAMETERS

### -AsString

Output result as string.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: Default
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: PathLocal
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: PathMerged
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: PathOnly
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Default

Returns the default bicep configuration

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: Default
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Local

Returns the settings in the local bicepconfig.json file

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: PathLocal
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Merged

Returns the merged settings from the local bicepconfig.json file and the default settings

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: PathMerged
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Path

Path to a bicep file

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: PathLocal
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: PathMerged
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: PathOnly
  Position: Named
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

Returns an object containing information about how bicep is configured at specified scope

## NOTES

## RELATED LINKS

- [Build-Bicep]()
- [Format-BicepFile]()
- [Test-BicepFile]()
