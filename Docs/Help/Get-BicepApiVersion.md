---
external help file: PSBicep.dll-Help.xml
Module Name: Bicep
online version:
schema: 2.0.0
---

# Get-BicepApiVersion

## SYNOPSIS
Get a list of API versions for a specific resource type.

## SYNTAX

```
Get-BicepApiVersion -ResourceType <String> [-Skip <Int32>] [-AvoidPreview]
 [<CommonParameters>]
```

## DESCRIPTION
This cmdlet retrieves the available API versions for a specified Azure resource type. It can be useful for determining which API versions are supported for a given resource.

## EXAMPLES

### Example 1
```
PS C:\> Get-BicepApiVersion -ResourceType "Microsoft.Compute/virtualMachines"
```

This command retrieves the API versions available for the "Microsoft.Compute/virtualMachines" resource type.

## PARAMETERS

### -AvoidPreview
This switch parameter indicates that preview API versions should be excluded from the results. If specified, only stable API versions will be returned.
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

### -ResourceType
Specifies the Azure resource type for which to retrieve API versions. This parameter is required.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Skip
Ignores the specified number of objects and then gets the remaining objects.
Useful when the latest version doesn't work and you want to use the next available version.
Enter the number of objects to skip.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable, -ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
