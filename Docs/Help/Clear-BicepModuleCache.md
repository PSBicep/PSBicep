---
external help file: Bicep-help.xml
Module Name: Bicep
online version:
schema: 2.0.0
---

# Clear-BicepModuleCache

## SYNOPSIS
Clear the local module cache.

## SYNTAX

### Oci
```
Clear-BicepModuleCache [-Oci] [[-Registry] <String>] [[-Repository] <String>] [[-Version] <String>]
 [<CommonParameters>]
```

### TemplateSpecs
```
Clear-BicepModuleCache [-TemplateSpecs] [[-SubscriptionId] <String>] [[-ResourceGroup] <String>]
 [[-Spec] <String>] [[-Version] <String>] [<CommonParameters>]
```

### All
```
Clear-BicepModuleCache [-All] [<CommonParameters>]
```

## DESCRIPTION
Command to clear all or parts of the local module cache. Supports clearing both modules cached from private registries and template specs.

## EXAMPLES

### Example 1 - Clear all cached modules from private registries
```powershell
Clear-BicepModuleCache -Oci
```

Removes all modules cached from private module registries (ACR).

### Example 2 - Clear all cached modules from template specs
```powershell
Clear-BicepModuleCache -TemplateSpecs
```

Removes all cached template specs.

### Example 3 - Clear all cached modules from a specific private registry
```powershell
Clear-BicepModuleCache -Oci -Registry mymodules.azurecr.io
```

Removes all modules cached from private module registry mymodules.azurecr.io

### Example 4 - Clear all cached modules from a template specs for a specific subscription
```powershell
Clear-BicepModuleCache -TemplateSpecs -SubscriptionID <subscription Id>
```

Removes all cached from template specs for a specific subscription.

### Example 5 - Removes a specific module from local module cache
```powershell
Clear-BicepModuleCache -Oci -Registry mymodules.azurecr.io -Repository Storage
```

Removes all cached versions of the module (repository) `Storage` from mymodules.azurecr.io.

### Example 6 - Removes a specific version from local module cache
```powershell
Clear-BicepModuleCache -Oci -Registry mymodules.azurecr.io -Repository Storage -Version v2
```

Removes version `v2` of the module (repository) `Storage` from mymodules.azurecr.io.

## PARAMETERS

### -All
Clear the entire cache

```yaml
Type: SwitchParameter
Parameter Sets: All
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Oci
Clear the cache for Bicep private registries

```yaml
Type: SwitchParameter
Parameter Sets: Oci
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Registry
Specifies which module registry to clear

```yaml
Type: String
Parameter Sets: Oci
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Repository
Specifies the repository to clear

```yaml
Type: String
Parameter Sets: Oci
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ResourceGroup
Specifies which resource group to clear

```yaml
Type: String
Parameter Sets: TemplateSpecs
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Spec
Specifies which template spec to clear

```yaml
Type: String
Parameter Sets: TemplateSpecs
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SubscriptionId
Specifies which subscription to clear

```yaml
Type: String
Parameter Sets: TemplateSpecs
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TemplateSpecs
Clear the cache for template specs

```yaml
Type: SwitchParameter
Parameter Sets: TemplateSpecs
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Version
Specifies which version of a cached module to clear

```yaml
Type: String
Parameter Sets: Oci, TemplateSpecs
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
