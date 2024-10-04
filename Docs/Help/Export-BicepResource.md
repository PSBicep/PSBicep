---
external help file: Bicep-help.xml
Module Name: Bicep
online version:
schema: 2.0.0
---

# Export-BicepResource

## SYNOPSIS
Exports a specified Azure resource as Bicep.

## SYNTAX

### Path (Default)
```
Export-BicepResource -ResourceId <String[]> [-IncludeTargetScope] -Path <String>
 [<CommonParameters>]
```

### AsString
```
Export-BicepResource -ResourceId <String[]> [-IncludeTargetScope] [-AsString]
 [<CommonParameters>]
```

## DESCRIPTION
Exports a specified Azure resource as Bicep.

## EXAMPLES

### Example 1
```
PS C:\> Export-BicepResource -ResourceId $ResourceId -Path 'C:\temp\myfile.bicep'
```

Exports a resource specified by resource id to the file "myfile.bicep".

### Example 2
```
PS C:\> Export-BicepResource -ResourceId $ResourceId -AsString
```

Exports a resource specified by resource id as a string.

## PARAMETERS

### -AsString
Specify that the resource will be exported as a string.

```yaml
Type: SwitchParameter
Parameter Sets: AsString
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeTargetScope
Include the target scope in the resulting exported resource string or file.

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

### -Path
The path to the Bicep file that the resource will be exported to.

```yaml
Type: String
Parameter Sets: Path
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ResourceId
The id of the resource to export.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable, -ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String[]
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
