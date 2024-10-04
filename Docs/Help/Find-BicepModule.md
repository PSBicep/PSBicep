---
external help file: Bicep-help.xml
Module Name: Bicep
online version:
schema: 2.0.0
---

# Find-BicepModule

## SYNOPSIS
Command to list modules in private Bicep module registries (ACR).

## SYNTAX

```
Find-BicepModule [[-Path] <String>] [[-Registry] <String>] [-Cache]
 [<CommonParameters>]
```

## DESCRIPTION
List all modules in a private Bicep module registry (ACR).

## EXAMPLES

### Example 1 - Find modules in a registry
```
Find-BicepModule -Registry psbicep.azurecr.io
```

Find and lists all modules stored in a Bicep module registry (ACR).

### Example 2 - Find modules in all registries in the local module cache
```
Find-BicepModule -Cache
```

Finds modules from all private Bicep module registries that are in the local module cache.

### Example 3 - Find modules in all registries referenced in a Bicep template
```
Find-BicepModule -Path .\storage.bicep
```

Finds modules from all private Bicep module registries referenced in the template \`storage.bicep\`.

## PARAMETERS

### -Cache
Find modules from registries in the local cache.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
Path to Bicep file.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Registry
URI to a Bicep registry (ACR)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable, -ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
