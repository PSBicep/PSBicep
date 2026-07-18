---
document type: cmdlet
external help file: PSBicep.dll-Help.xml
HelpUri: ''
Locale: en-US
Module Name: Bicep
ms.date: 07/18/2026
PlatyPS schema version: 2024-05-01
title: Get-BicepResourceProvider
---

# Get-BicepResourceProvider

## SYNOPSIS

Gets Azure resource provider namespaces available to Bicep, optionally filtered by a case-insensitive name prefix.

## SYNTAX

### byName (Default)

```
Get-BicepResourceProvider [[-ResourceProvider] <string>] [-ExactMatch] [<CommonParameters>]
```

### byFullyQualifiedName

```
Get-BicepResourceProvider [-ExactMatch] [-FullyQualifiedName <string>] [<CommonParameters>]
```

## ALIASES

## DESCRIPTION

The cmdlet reads Bicep's available resource types and returns each distinct Azure resource provider namespace. Use `ResourceProvider` or the one-segment `FullyQualifiedName` parameter to limit results by a case-insensitive prefix.

## EXAMPLES

### Example 1

This example returns all distinct Azure resource provider namespaces available in the loaded Bicep type definitions.

```powershell
Get-BicepResourceProvider
```

## PARAMETERS

### -ExactMatch

Requires the resource provider namespace to match exactly instead of treating the supplied value as a prefix. Matching remains case-insensitive.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: byName
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: byFullyQualifiedName
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -FullyQualifiedName

The resource provider namespace to retrieve.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: byFullyQualifiedName
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -ResourceProvider

The resource provider namespace to retrieve.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: byName
  Position: 0
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

## OUTPUTS

### System.String

Returns each matching distinct Azure resource provider namespace as a string.

## NOTES

Results come from the resource type definitions bundled with the loaded Bicep version; the cmdlet does not query an Azure subscription.

## RELATED LINKS

- [Get-BicepResourceType]()
- [Get-BicepChildResourceType]()
- [Get-BicepApiVersion]()
