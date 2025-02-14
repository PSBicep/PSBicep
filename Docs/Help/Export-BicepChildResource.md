---
external help file: Bicep-help.xml
Module Name: Bicep
online version:
schema: 2.0.0
---

# Export-BicepChildResource

## SYNOPSIS
Exports all child resources of a specified Azure resource container as Bicep.

## SYNTAX

```
Export-BicepChildResource [-ParentResourceId] <String> [-IncludeTargetScope]
 [<CommonParameters>]
```

## DESCRIPTION
Exports all child resources of a specified Azure resource container as Bicep.

## EXAMPLES

### Example 1
```
PS C:\> Export-BicepChildResource -ParentResourceId $ParentResourceId -OutputDirectory $Path
```

Exports all child resources from an Azure resource container by id.

## PARAMETERS

### -ParentResourceId
The resource id of the resource container, or parent resource.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -IncludeTargetScope
Will add a TargetScope declaration to the start of each template.

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
