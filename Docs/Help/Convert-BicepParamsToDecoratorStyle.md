---
external help file: Bicep-help.xml
Module Name: Bicep
online version:
schema: 2.0.0
---

# Convert-BicepParamsToDecoratorStyle (Decommissioned)

## SYNOPSIS
Convert Bicep parameters from v0.1-0.2 style to decorator style.

>NOTE: This command has been decommissioned since parameter modifiers are no longer supported starting with Bicep 0.4. If you have old bicep files that you need to update to use decorator style parameters use version 1.4.7 of the module that is using an older Bicep version.

## SYNTAX

```
Convert-BicepParamsToDecoratorStyle -Path <String> [-ToClipboard] [<CommonParameters>]
```

## DESCRIPTION
This command convert Bicep parameters from v0.1-0.2 style to decorator style using a bicep file as input.

## EXAMPLES

### Example 1: Convert parameters from one bicep file to decorator style parameters
```powershell
Convert-BicepParamsToDecoratorStyle -Path .\VirtualHubVPNGateway.bicep
```

This example takes a bicep file as input and converts all parameters to decorator style parameters and outputs the result.

### Example 2: Convert parameters from one bicep file to decorator style parameters and save to clipboard
```powershell
Convert-BicepParamsToDecoratorStyle -Path .\VirtualHubVPNGateway.bicep -ToClipboard
```

This example takes a bicep file as input and converts all parameters to decorator style parameters saves the result to the clipboard.

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

### -ToClipboard  (Windows only)
Saves the converted params to the clipboard.

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

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
