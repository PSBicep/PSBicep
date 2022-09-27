---
external help file: Bicep-help.xml
Module Name: Bicep
online version:
schema: 2.0.0
---

# Get-BicepMetadata

## SYNOPSIS
Get metadata from a Bicep template

## SYNTAX

```
Get-BicepMetadata [-Path] <String> [[-OutputType] <String>] [-SkipGeneratorMeta] [<CommonParameters>]
```

## DESCRIPTION
Get metadata from a Bicep template

## EXAMPLES

### Example 1 - Get metadata from Bicep file
```powershell
Get-BicepMetadata -Path .\myTemplate.bicep
```

Get metadata from Bicep file

### Example 2 - Get metadata from Bicep file and output as Json
```powershell
Get-BicepMetadata -Path .\myTemplate.bicep -OutputType Json
```

Get metadata from Bicep file and output as json

### Example 3 - Get metadata from Bicep file and output as hashtable
```powershell
Get-BicepMetadata -Path .\myTemplate.bicep -OutputType Hashtable
```

Get metadata from Bicep file and output as hashtable

### Example 4 - Get metadata from Bicep file and skip _generator metadata
```powershell
Get-BicepMetadata -Path .\myTemplate.bicep -SkipGeneratorMeta
```

Get metadata from Bicep file and skip `_generator` metadata

## PARAMETERS

### -OutputType
Specify output type

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Simple, Json, Hashtable

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
Path to Bicep file

```yaml
Type: String
Parameter Sets: (All)
Aliases: PSPath

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SkipGeneratorMeta
Skip _generator metadata

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
