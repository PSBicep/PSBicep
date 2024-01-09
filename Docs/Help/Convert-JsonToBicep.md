---
external help file: Bicep-help.xml
Module Name: Bicep
online version:
schema: 2.0.0
---

# Convert-JsonToBicep

## SYNOPSIS
Convert a JSON string or file to Bicep

## SYNTAX

### String
```
Convert-JsonToBicep -String <String> [-ToClipboard] [<CommonParameters>]
```

### Path
```
Convert-JsonToBicep [-Path <String>] [-ToClipboard] [<CommonParameters>]
```

## DESCRIPTION
This command converts any valid JSON object to Bicep Language format

## EXAMPLES

### Example 1: Convert a json object to Bicep Language
```powershell
Convert-JsonToBicep -String '{"key": "value", "anotherKey": "anotherValue"}'
```

This example converts a simple JSON object to Bicep Language

### Example 2: Convert a json array to Bicep Language
```powershell
$json = @'
[
  {
    "properties": {
      "NSGName": "subnet2-nsg",
      "SubnetName": "subnet2",
      "RouteName": "",
      "disableBgpRoutePropagation": true,
      "routes": []
    }
  },
  {
    "properties": {
      "NSGName": "subnet3-nsg",
      "SubnetName": "subnet3",
      "RouteName": "",
      "disableBgpRoutePropagation": false,
      "routes": []
    }
  }
]
'@
Convert-JsonToBicep -String $json
```

This example converts a JSON array to Bicep Language

### Example 3: Read a file and convert to Bicep Language
```powershell
Get-Content -Path <path to .json file> -Raw | Convert-JsonToBicep
```

This example converts a JSON file to Bicep Language

### Example 4: Converts a JSON-file to bicep
```powershell
Convert-JsonToBicep -path <path to .json-file>
```

This example converts a JSON file to Bicep Language

### Example 5: Converts a JSON-file to bicep and saves it to the Clipboard
```powershell
Convert-JsonToBicep -path <path to .json-file> -ToClipboard
```

This example converts a JSON file to Bicep Language and saves it to the Clipboard

## PARAMETERS

### -Path
Specifies the JSON file to convert to Bicep Language

```yaml
Type: String
Parameter Sets: Path
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -String
Specifies the JSON string to convert to Bicep Language

```yaml
Type: String
Parameter Sets: String
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -ToClipboard
Copies the result to the clipboard.

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable, -ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
