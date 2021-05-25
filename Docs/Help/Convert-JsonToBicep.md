---
external help file:
Module Name:
online version:
schema: 2.0.0
---

# Convert-JsonToBicep

## SYNOPSIS
Convert a JSON string to Bicep

## SYNTAX

```
Convert-JsonToBicep -String <String> [-ToClipboard] [<CommonParameters>]
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

### Example 3: Read a file and convert it to Bicep Language
```powershell
Get-Content -Path <path to .json file> -Raw | Convert-JsonToBicep
```

This example converts a JSON file to Bicep Language

### Example 4: Read a file, convert it to Bicep Language and save the output to the Clipboard
```powershell
Get-Content -Path <path to .json file> -Raw | Convert-JsonToBicep -ToClipboard
```

This example reads a file, converts it to Bicep Language and then saves the output to the Clipboard

## PARAMETERS

### -String
Specifies the JSON string to convert to Bicep Language

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

### -ToClipboard
{{ Fill ToClipboard Description }}

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
