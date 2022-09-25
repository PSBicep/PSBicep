---
external help file: Bicep-help.xml
Module Name: Bicep
online version:
schema: 2.0.0
---

# Get-BicepConfig

## SYNOPSIS
Get bicep configuration (bicepconfig.json) in use for a bicep file.

## SYNTAX

### Default (Default)
```
Get-BicepConfig [-Default] [<CommonParameters>]
```

### PathMerged
```
Get-BicepConfig -Path <String> [-Merged] [<CommonParameters>]
```

### PathLocal
```
Get-BicepConfig -Path <String> [-Local] [<CommonParameters>]
```

### PathOnly
```
Get-BicepConfig -Path <String> [<CommonParameters>]
```

## DESCRIPTION
Command to get the bicep configuration in use for a specific Bicep file. Will return path to the bicepconfig.json file as well as the current settings.

## EXAMPLES

### Example 1 - Get bicep configuration for a bicep file
```powershell
Get-BicepConfig -Path .\storage.bicep
```

### Example 2 - Get the merged bicep configuration for a bicep file
```powershell
Get-BicepConfig -Path .\storage.bicep -Merged
```

Returns the path to the bicepconfig.json file in use, and the merged settings (default + local file).


### Example 3 - Get the local bicep configuration for a bicep file
```powershell
Get-BicepConfig -Path .\storage.bicep -Merged
```

Returns the path to the bicepconfig.json file in use, and the settings in the local bicepconfig.json.

### Example 4 - Get the default bicep configuration
```powershell
Get-BicepConfig -Default
```

Returns the default settings.

## PARAMETERS

### -Default
Returns the default bicep configuration

```yaml
Type: SwitchParameter
Parameter Sets: Default
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Local
Returns the settings in the local bicepconfig.json file

```yaml
Type: SwitchParameter
Parameter Sets: PathLocal
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Merged
Returns the merged settings from the local bicepconfig.json file and the default settings

```yaml
Type: SwitchParameter
Parameter Sets: PathMerged
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
Path to a bicep file

```yaml
Type: String
Parameter Sets: PathMerged, PathLocal, PathOnly
Aliases:

Required: True
Position: Named
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
