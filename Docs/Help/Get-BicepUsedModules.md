---
external help file: Bicep-help.xml
Module Name: Bicep
online version:
schema: 2.0.0
---

# Get-BicepUsedModules

## SYNOPSIS

Get modules used in a Bicep file.

## SYNTAX

```
Get-BicepUsedModules [-Path] <String> [<CommonParameters>]
```

## DESCRIPTION

Get information about modules used in a Bicep file.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-BicepUsedModules -Path $BicepFilePath
```

Get all modules from a specific Bicep file.

## PARAMETERS

### -Path

The path to the Bicep file.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
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
