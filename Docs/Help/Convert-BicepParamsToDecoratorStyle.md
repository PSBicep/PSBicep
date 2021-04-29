---
external help file: Bicep-help.xml
Module Name: Bicep
online version:
schema: 2.0.0
---

# Convert-BicepParamsToDecoratorStyle

## SYNOPSIS
Convert Bicep parameters from v0.1-0.2 style to decorator style.

## SYNTAX

```
Convert-BicepParamsToDecoratorStyle -Path <String> [<CommonParameters>]
```

## DESCRIPTION
This command convert Bicep parameters from v0.1-0.2 style to decorator style using a bicep file as input.

## EXAMPLES

### Example 1: Convert parameters from one bicep file to decorator style parameters
```powershell
Convert-BicepParamsToDecoratorStyle -Path .\VirtualHubVPNGateway.bicep
```

This example takes a bicep file as input and converts all parameters to decorator style parameters and outputs the result.

## PARAMETERS

### -Path
Specfies the path to the file with parameters to convert

```yaml
Type: String
Parameter Sets: (All)
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
