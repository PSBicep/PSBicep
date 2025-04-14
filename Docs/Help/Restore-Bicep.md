---
external help file: Bicep-help.xml
Module Name: Bicep
online version:
schema: 2.0.0
---

# Restore-Bicep

## SYNOPSIS
Restores external modules from the specified Bicep file to the local module cache.

## SYNTAX

```
Restore-Bicep [-Path] <String> [-Force] [<CommonParameters>]
```

## DESCRIPTION
Restores all external modules referenced in the .bicep file to the local module cache.
Modules from an ACR bicep registry is stored under '%USERPROFILE%\.bicep\br' and template spec modules '%USERPROFILE%\.bicep\ts'.

## EXAMPLES

### Example 1
```
Restore-Bicep -Path .\main.bicep
```

Restores all external modules used in main.bicep to the local module cache.

## PARAMETERS

### -Path
Bicep file to restore.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
{{ Fill Force Description }}

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable, -ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
