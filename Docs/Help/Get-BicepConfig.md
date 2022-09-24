---
external help file: Bicep-help.xml
Module Name: Bicep
online version:
schema: 2.0.0
---

# Get-BicepConfig

## SYNOPSIS
Command used to find the bicepconfig.json and configuration in use

## SYNTAX

```
Get-BicepConfig [[-Path] <String>] [[-Scope] <String>] [<CommonParameters>]
```

## DESCRIPTION
Command used to find the bicepconfig.json file in use and the current configuration. Shows either the configuration in the local bicepconfig.json file, the merged config or the default config.

## EXAMPLES

### Example 1 - Get the default bicepconfig
```powershell
$bicepConfig=Get-BicepConfig -Scope Default
$bicepConfig.Config
```

Gets the default configuration built in to Bicep

### Example 2 - Get the merged bicepconfig
```powershell
$bicepConfig=Get-BicepConfig -Scope Merged -Path c:\bicepTemplates\storage.bicep
$bicepConfig.Config
```

Gets the merged configuration in use for a Bicep file

### Example 3 - Get the local bicepconfig
```powershell
$bicepConfig=Get-BicepConfig -Scope Local -Path c:\bicepTemplates\storage.bicep
$bicepConfig.Config
```

Gets the local configuration in use for a Bicep file

### Example 4 - Find the path to the bicepconfig.json in use
```powershell
Get-BicepConfig -Path c:\bicepTemplates\storage.bicep
```

Returns the path to the bicepconfig.json in use and config

## PARAMETERS

### -Path
Path to a bicep file

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

### -Scope
Scope of the config. `Local` returns the config in the current bicepconfig.json, `Merged` returns the merged config (local file and bicep default config), `Default` returns the default config.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Local, Merged, Default

Required: False
Position: 1
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
