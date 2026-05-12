---
document type: cmdlet
external help file: Bicep-help.xml
HelpUri: ''
Locale: en-US
Module Name: Bicep
ms.date: 05-11-2026
PlatyPS schema version: 2024-05-01
title: Find-BicepModule
---

# Find-BicepModule

## SYNOPSIS

Command to list modules in private Bicep module registries (ACR).

## SYNTAX

### Path

```
Find-BicepModule [-Path] <string> [-Registry <string>] [<CommonParameters>]
```

### Registry

```
Find-BicepModule [-Registry] <string> [[-ConfigurationPath] <string>] [<CommonParameters>]
```

### Cache

```
Find-BicepModule -Cache [-Registry <string>] [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  None


## DESCRIPTION

List all modules in a private Bicep module registry (ACR).

## EXAMPLES

### Example 1 - Find modules in a registry

Find-BicepModule -Registry psbicep.azurecr.io

Find and lists all modules stored in a Bicep module registry (ACR).

### Example 2 - Find modules in all registries in the local module cache

Find-BicepModule -Cache

Finds modules from all private Bicep module registries that are in the local module cache.

### Example 3 - Find modules in all registries referenced in a Bicep template

Find-BicepModule -Path .\storage.bicep

Finds modules from all private Bicep module registries referenced in the template `storage.bicep`.

## PARAMETERS

### -Cache

Find modules from registries in the local cache.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: Cache
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -ConfigurationPath

Path to a bicepconfig.json file for specifying registry configuration when searching for modules.

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: Registry
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

Path to Bicep file.

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: Path
  Position: 1
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Registry

URI to a Bicep registry (ACR)

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: Registry
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

Returns an array of found Bicep modules with their names, versions, and source locations.

## NOTES

This command searches for Bicep modules from three sources: a local file path, a Bicep registry, or the local module cache. When searching by path, it validates that the Bicep file is buildable before finding modules.

## RELATED LINKS

- [Restore-Bicep]()
- [Publish-Bicep]()
- [Bicep Documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
- [PSBicep Repository](https://github.com/PSBicep/PSBicep)
