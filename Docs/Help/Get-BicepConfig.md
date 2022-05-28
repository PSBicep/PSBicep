---
external help file: Bicep-help.xml
Module Name: Bicep
online version:
schema: 2.0.0
---

# Get-BicepConfig

## SYNOPSIS
Get bicepconfig.json file in use for a Bicep template.

## SYNTAX

```
Get-BicepConfig [[-Path] <String>] [<CommonParameters>]
```

## DESCRIPTION
Finds the bicepconfig.json file in use for a Bicep template.

## EXAMPLES

### Example 1: Find bicepconfig.json for a Bicep template
```powershell
Get-BicepConfig -Path C:\bicep\storage.bicep
```

Finds the `bicepconfig.json` file in use for Bicep template storage.bicep.

### Example 2: Find bicepconfig.json for a Bicep template and output the settings
```powershell
$myConfig=Get-BicepConfig -Path C:\bicep\storage.bicep
$myConfig.Config
```

Finds the `bicepconfig.json` file in use for Bicep template storage.bicep and outputs the settings defined in the file.

## PARAMETERS

### -Path
Path to a Bicep template

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
