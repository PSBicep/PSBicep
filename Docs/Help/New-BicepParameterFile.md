---
external help file: Bicep-help.xml
Module Name: Bicep
online version:
schema: 2.0.0
---

# New-BicepParameterFile

## SYNOPSIS

Creates an ARM Template parameter file based on a bicep file.

## SYNTAX

```
New-BicepParameterFile [-Path] <String> [-Parameters <String>] [[-OutputDirectory] <String>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

Creates an ARM Template parameter file based on a bicep file. The parameter file can be used during deployment with Azure CLI or Azure PowerShell.

## EXAMPLES

### Example 1: Generate an ARM Template parameter file for a bicep file

```powershell
New-BicepParameterFile -Path 'AzureFirewall.bicep'
```

Creates a parameter file called AzureFirewall.parameters.json in the same directory as the bicep file.

### Example 2: Generate an ARM Template parameter file for a bicep file with all parameters from the bicep file

```powershell
New-BicepParameterFile -Path 'AzureFirewall.bicep' -Parameters All
```

Creates a parameter file called AzureFirewall.parameters.json in the same directory as the bicep file.

### Example 3: Creates a parameter file in the specified directory

```powershell
New-BicepParameterFile -Path 'AzureFirewall.bicep' -OutputDirectory 'd:\myfolder\'
```

Creates a parameter file in the specified directory.

## PARAMETERS

### -Confirm

Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutputDirectory

Specifies the directory where the parameter file should be stored.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path

Path to the bicep file which the parameter file should be created from.

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

### -WhatIf

Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Parameters
Specify which parameters should be exported to the parameter file.

```yaml
Type: String
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
