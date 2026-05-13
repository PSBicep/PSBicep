---
document type: cmdlet
external help file: Bicep-help.xml
HelpUri: ''
Locale: en-US
Module Name: Bicep
ms.date: 05/13/2026
PlatyPS schema version: 2024-05-01
title: Clear-BicepModuleCache
---

# Clear-BicepModuleCache

## SYNOPSIS

Clear the local module cache.

## SYNTAX

### Oci (Default)

```
Clear-BicepModuleCache [-Oci] [[-Registry] <string>] [[-Repository] <string>] [[-Path] <string>]
 [[-Version] <string>] [<CommonParameters>]
```

### TemplateSpecs

```
Clear-BicepModuleCache [-TemplateSpecs] [[-SubscriptionId] <string>] [[-ResourceGroup] <string>]
 [[-Spec] <string>] [[-Path] <string>] [[-Version] <string>] [<CommonParameters>]
```

### All

```
Clear-BicepModuleCache [-All] [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  None


## DESCRIPTION

Command to clear all or parts of the local module cache.
Supports clearing both modules cached from private registries and template specs.

## EXAMPLES

### Example 1 - Clear all cached modules from private registries

Clear-BicepModuleCache -Oci

Removes all modules cached from private module registries (ACR).

### Example 2 - Clear all cached modules from template specs

Clear-BicepModuleCache -TemplateSpecs

Removes all cached template specs.

### Example 3 - Clear all cached modules from a specific private registry

Clear-BicepModuleCache -Oci -Registry mymodules.azurecr.io

Removes all modules cached from private module registry mymodules.azurecr.io

### Example 4 - Clear all cached modules from a template specs for a specific subscription

Clear-BicepModuleCache -TemplateSpecs -SubscriptionID <subscription Id>

Removes all cached from template specs for a specific subscription.

### Example 5 - Removes a specific module from local module cache

Clear-BicepModuleCache -Oci -Registry mymodules.azurecr.io -Repository Storage

Removes all cached versions of the module (repository) `Storage` from mymodules.azurecr.io.

### Example 6 - Removes a specific version from local module cache

Clear-BicepModuleCache -Oci -Registry mymodules.azurecr.io -Repository Storage -Version v2

Removes version `v2` of the module (repository) `Storage` from mymodules.azurecr.io.

## PARAMETERS

### -All

Clear the entire cache

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: All
  Position: 1
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Oci

Clear the cache for Bicep private registries

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: Oci
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

The path used to lookup appropriate bicepconfig.json to determine cache location.

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: TemplateSpecs
  Position: 5
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: Oci
  Position: 4
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Registry

Specifies which module registry to clear

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: Oci
  Position: 2
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Repository

Specifies the repository to clear

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: Oci
  Position: 3
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -ResourceGroup

Specifies which resource group to clear

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: TemplateSpecs
  Position: 3
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Spec

Specifies which template spec to clear

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: TemplateSpecs
  Position: 4
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -SubscriptionId

Specifies which subscription to clear

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: TemplateSpecs
  Position: 2
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -TemplateSpecs

Clear the cache for template specs

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: TemplateSpecs
  Position: 1
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Version

Specifies which version of a cached module to clear

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: TemplateSpecs
  Position: 6
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: Oci
  Position: 5
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

None

## NOTES

## RELATED LINKS

- [Restore-Bicep]()
- [Get-BicepConfig]()
- [Get-BicepUsedModules]()
