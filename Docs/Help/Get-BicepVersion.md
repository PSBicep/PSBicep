---
external help file: Bicep-help.xml
Module Name: Bicep
online version:
schema: 2.0.0
---

# Get-BicepVersion

## SYNOPSIS
View the installed version and the latest available version of Bicep CLI.

## SYNTAX

```
Get-BicepVersion [-All] [<CommonParameters>]
```

## DESCRIPTION
Get-BicepVersion is a command to compare the installed version of Bicep CLI with the latest release available in the Azure/Bicep repo.

## EXAMPLES

### Example 1: Compare installed version with latest release
```powershell
Get-BicepVersion
```

## PARAMETERS

### -All
Gets all available Bicep versions.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Go to module repository https://github.com/PSBicep/PSBicep for detailed info, reporting issues and to submit contributions.

## RELATED LINKS
