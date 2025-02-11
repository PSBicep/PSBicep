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

### ByQueryOutStream
```
Export-BicepResource -KQLQuery <String> [-UseKQLResult] [-IncludeTargetScope] [-RemoveUnknownProperties]
 [-AsString] [-Raw] [<CommonParameters>]
```

### ByQueryOutPath
```
Export-BicepResource -KQLQuery <String> [-UseKQLResult] -OutputDirectory <String> [-IncludeTargetScope]
 [-RemoveUnknownProperties] [-Raw] [<CommonParameters>]
```

### ByIdOutStream
```
Export-BicepResource -ResourceId <String[]> [-IncludeTargetScope] [-RemoveUnknownProperties] [-AsString] [-Raw]
 [<CommonParameters>]
```

### ByIdOutPath
```
Export-BicepResource -ResourceId <String[]> -OutputDirectory <String> [-IncludeTargetScope]
 [-RemoveUnknownProperties] [-Raw] [<CommonParameters>]
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
Parameter Sets: ByQueryOutStream, ByIdOutStream
Aliases:

Required: False
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

### -ResourceId
The id of the resource to export.

```yaml
Type: String[]
Parameter Sets: ByIdOutStream, ByIdOutPath
Aliases: id

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -KQLQuery
Query for Azure Resource Graph to select resources to export. Must include the property id containing a resource id for each resource.

```yaml
Type: String
Parameter Sets: ByQueryOutStream, ByQueryOutPath
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutputDirectory
Path to directory where output files will be saved.

```yaml
Type: String
Parameter Sets: ByQueryOutPath, ByIdOutPath
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Raw
Output raw json without converting to bicep.

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

### -RemoveUnknownProperties
Will use a rewriter to strip any property not defined in the resource schema. This can help to produce deployable templates but also has a risk of removing useful data, use with caution.

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

### -UseKQLResult
Use resource body directly from KQL query result intead of getting the actual resource body.

```yaml
Type: SwitchParameter
Parameter Sets: ByQueryOutStream, ByQueryOutPath
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

### System.String[]
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
