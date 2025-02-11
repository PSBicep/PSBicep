---
external help file: Bicep-help.xml
Module Name: Bicep
online version:
schema: 2.0.0
---

# Publish-Bicep

## SYNOPSIS
Publishes a .bicep file to the module registry.

## SYNTAX

```
Publish-Bicep [-Path] <String> [-Target] <String> [-DocumentationUri <String>] [-PublishSource] [-Force]
 [<CommonParameters>]
```

## DESCRIPTION
Publishes .bicep files to the module registry repository specified.

## EXAMPLES

### Example 1
```
Publish-Bicep -Path .\storage.bicep -Target br:psbicep.azurecr.io/bicep/storage:v1
```

Publishes storage.bicep as a module in the private module registry psbicep.azurecr.io, to the repository bicep/storage using the v1 tag.

## PARAMETERS

### -Path
Specifies which bicep file to publish.

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

### -Target
Specifies the target registry, repository and tag.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
Overwrites any existing published file.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -DocumentationUri
Uri to documentation for the module.

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

### -PublishSource
Attach the bicep source code to the published module.

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
