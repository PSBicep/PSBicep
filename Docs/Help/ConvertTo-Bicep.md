---
external help file: Bicep-help.xml
Module Name: Bicep
online version:
schema: 2.0.0
---

# ConvertTo-Bicep

## SYNOPSIS
Decompile ARM templates to .bicep files

## SYNTAX

```
ConvertTo-Bicep [[-Path] <String>] [[-OutputDirectory] <String>] [-AsString] [-Force]
 [<CommonParameters>]
```

## DESCRIPTION
ConvertTo-Bicep is equivalent to 'bicep decompile' but with some additional features.

-Decompile all ARM templates in a directory -Specify output directory

## EXAMPLES

### Example 1: Decompile single json file in working directory
```
ConvertTo-Bicep -Path vnet.json
```

### Example 2: Decompile all ARM template json files in the provided directory
```
ConvertTo-Bicep -Path 'c:\armtemplates\'
```

### Example 3: Decompile single json file in working directory
```
ConvertTo-Bicep -Path vnet.json -OutputDirectory 'c:\bicep\modules\'
```

### Example 4: Decompile single json file and output as a string
```
ConvertTo-Bicep -Path vnet.json -AsString
```

## PARAMETERS

### -AsString
-AsString prints all output as a string instead of corresponding files.

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

### -Force
Force overwriting of output files.
If the output.bicep file already exists and -Force is not set we will not overwrite the resulting file.

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

### -OutputDirectory
Specifies the path to the directory where the compiled files should be outputted

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
Specfies the path to the directory or file that should be decompiled

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: $pwd.path
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable, -ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Go to module repository https://github.com/PSBicep/PSBicep for detailed info, reporting issues and to submit contributions.

## RELATED LINKS
