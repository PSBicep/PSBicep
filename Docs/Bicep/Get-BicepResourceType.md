---
document type: cmdlet
external help file: PSBicep.dll-Help.xml
HelpUri: ''
Locale: en-US
Module Name: Bicep
ms.date: 07/18/2026
PlatyPS schema version: 2024-05-01
title: Get-BicepResourceType
---

# Get-BicepResourceType

## SYNOPSIS

Gets available top-level Azure resource types, optionally filtering by an exact provider name and a resource-type name prefix and returning short or fully qualified names.

## SYNTAX

### byName (Default)

```
Get-BicepResourceType [[-ResourceProvider] <string>] [[-Resource] <string>]
 [-OutputFullyQualifiedName] [-ExactMatch] [<CommonParameters>]
```

### byFullyQualifiedName

```
Get-BicepResourceType [-FullyQualifiedName <string>] [-OutputFullyQualifiedName] [-ExactMatch]
 [<CommonParameters>]
```

## ALIASES

## DESCRIPTION

Queries Bicep's Azure resource type definitions for top-level resource types. You can filter results by an exact provider name and a type-name prefix or use a fully qualified name, and request fully qualified output.

## EXAMPLES

### Example 1

Retrieves matching top-level resource type names. By default, the output contains short type names; use `-OutputFullyQualifiedName` to include the provider name.

```powershell
Get-BicepResourceType
```

## PARAMETERS

### -ExactMatch

Matches the resource type name exactly instead of treating `-Resource` as a prefix. Matching remains case-insensitive.

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

The fully qualified resource type to retrieve.

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

### -OutputFullyQualifiedName

Returns each resource type as a fully qualified provider/type name. Without this switch, the cmdlet returns only the resource type name.

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

### -Resource

The name of the resource type to retrieve.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: byName
  Position: 1
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -ResourceProvider

The name of the resource provider to retrieve resource types for.

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

Returns distinct strings containing matching resource type names. With `-OutputFullyQualifiedName`, each string uses the provider/type format; otherwise, it contains only the resource type name.

## NOTES

Filtering is case-insensitive. A supplied provider name is matched exactly; resource type names use prefix matching unless `-ExactMatch` is specified. This cmdlet returns only top-level types; use `Get-BicepChildResourceType` for child resource types.

## RELATED LINKS

- [Get-BicepResourceProvider]()
- [Get-BicepChildResourceType]()
- [Get-BicepApiVersion]()
