---
document type: cmdlet
external help file: Bicep-help.xml
HelpUri: ''
Locale: en-US
Module Name: Bicep
ms.date: 05/13/2026
PlatyPS schema version: 2024-05-01
title: Convert-JsonToBicep
---

# Convert-JsonToBicep

## SYNOPSIS

Convert a JSON string or file to Bicep

## SYNTAX

### String

```
Convert-JsonToBicep -String <string> [-ToClipboard] [<CommonParameters>]
```

### Path

```
Convert-JsonToBicep [-Path <string>] [-ToClipboard] [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  None


## DESCRIPTION

This command converts any valid JSON object to Bicep Language format

## EXAMPLES

### Convert a json object to Bicep Language

Convert-JsonToBicep -String '{"key": "value", "anotherKey": "anotherValue"}'

This example converts a simple JSON object to Bicep Language

### Convert a json array to Bicep Language

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

This example converts a JSON array to Bicep Language

### Read a file and convert to Bicep Language

Get-Content -Path <path to .json file> -Raw | Convert-JsonToBicep

This example converts a JSON file to Bicep Language

### Converts a JSON-file to bicep

Convert-JsonToBicep -path <path to .json-file>

This example converts a JSON file to Bicep Language

### Converts a JSON-file to bicep and saves it to the Clipboard

Convert-JsonToBicep -path <path to .json-file> -ToClipboard

This example converts a JSON file to Bicep Language and saves it to the Clipboard

## PARAMETERS

### -Path

Specifies the JSON file to convert to Bicep Language

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: Path
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -String

Specifies the JSON string to convert to Bicep Language

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: String
  Position: Named
  IsRequired: true
  ValueFromPipeline: true
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -ToClipboard

Copies the result to the clipboard.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

Accepts a JSON string input from the pipeline. The string should contain a valid ARM template in JSON format.

## OUTPUTS

### System.Object

Returns the converted Bicep code as a string. When -ToClipboard is used on Windows, also copies the output to the system clipboard.

## NOTES

This command converts ARM JSON templates to Bicep syntax. It validates the JSON input, converts it to a hashtable representation, and processes it through the Bicep decompiler.

## RELATED LINKS

- [ConvertTo-Bicep]()
- [Bicep Documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
- [PSBicep Repository](https://github.com/PSBicep/PSBicep)
