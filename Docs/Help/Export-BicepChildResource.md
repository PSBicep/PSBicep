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

### OutputPath (Default)

```powershell
Export-BicepChildResource [-ParentResourceId] <String> [-OutputDirectory] <String> [<CommonParameters>]
```

### AsString

```powershell
Export-BicepChildResource [-ParentResourceId] <String> [-AsString] [<CommonParameters>]
```

## DESCRIPTION

Exports all child resources of a specified Azure resource container as Bicep.

## EXAMPLES

### Example 1

```powershell
PS C:\> Export-BicepChildResource -ParentResourceId $ParentResourceId -OutputDirectory $Path
```

Exports all child resources from an Azure resource container by id.

## PARAMETERS

### -AsString

Exports the resources as string.

```yaml
Type: SwitchParameter
Parameter Sets: AsString
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutputDirectory

Specifies the directory to output the Bicep files to.

```yaml
Type: String
Parameter Sets: OutputPath
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ParentResourceId

The resource id of the resource container, or parent resource.

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
