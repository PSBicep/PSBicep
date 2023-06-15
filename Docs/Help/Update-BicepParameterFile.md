---
external help file: Bicep-help.xml
Module Name: Bicep
online version:
schema: 2.0.0
---

# Update-BicepParameterFile

## SYNOPSIS

Updates existing ARM Template parameter file based on a bicep file.

## SYNTAX

```
Update-BicepParameterFile [-Path] <String> [[-BicepFile] <String>] [[-Parameters] <String>]
 [<CommonParameters>]
```

## DESCRIPTION

Updates a parameter file with new parameters, without removing existing values. Also removes parameters from the parameter file if they have been removed from the bicep file.

## EXAMPLES

### Example 1

```powershell
PS C:\> Update-BicepParameterFile -Path .\vnet.parameters.json
```

Update a parameter file vnet.parameters.json, without specifying the name of the bicep file. It will look for a bicep file in the same directory with a name based on the parameterfile. In this case vnet.bicep.

### Example 2

```powershell
PS C:\> Update-BicepParameterFile -Path .\vnet.parameters.json -BicepFile .\bicepfiles\virtualnetwork.bicep
```

Update a parameter file vnet.parameters.json, specifying the location of the bicep file.

## PARAMETERS

### -BicepFile

Path to the bicep file which the parameter file should be updated from.

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

### -Parameters

Whether or not to update the parameter file with all parameters or only the required ones.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: All, Required

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path

Path to the parameters.json file that needs updating.

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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
