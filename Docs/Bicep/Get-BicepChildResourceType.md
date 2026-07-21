---
document type: cmdlet
external help file: PSBicep.dll-Help.xml
HelpUri: ''
Locale: en-US
Module Name: Bicep
ms.date: 07/18/2026
PlatyPS schema version: 2024-05-01
title: Get-BicepChildResourceType
---

# Get-BicepChildResourceType

## SYNOPSIS

Gets available Azure child resource type names from Bicep's type definitions, optionally filtered by resource provider, parent resource type, and child type name. Use `-OutputFullyQualifiedName` to return provider-qualified names.

## SYNTAX

### byName (Default)

```
Get-BicepChildResourceType [[-ResourceProvider] <string>] [[-Resource] <string>] [[-Child] <string>]
 [-OutputFullyQualifiedName] [-ExactMatch] [<CommonParameters>]
```

### byFullyQualifiedName

```
Get-BicepChildResourceType [-FullyQualifiedName <string>] [-OutputFullyQualifiedName] [-ExactMatch]
 [<CommonParameters>]
```

## ALIASES

## DESCRIPTION

Queries the Bicep type definitions for child resource types. Provider and parent filters match exactly, while the child filter matches by prefix unless `-ExactMatch` is specified.

## EXAMPLES

### Example 1

This example lists the available child resource type names from the loaded Bicep type definitions.

```powershell
Get-BicepChildResourceType
```

## PARAMETERS

### -Child

The name of the child resource type to retrieve.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: byName
  Position: 2
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -ExactMatch

Requires the complete child resource type path supplied by `Child` or `FullyQualifiedName` to match exactly, ignoring case. Without this switch, the child path is treated as a case-insensitive prefix.

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

The fully qualified name of the child resource type to retrieve.

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

Returns each matching child resource type with its resource provider and parent type, for example `Microsoft.Network/virtualNetworks/subnets`. By default, only the child portion of the type name is returned.

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

The cmdlet writes one string for each unique matching child resource type, either as the child portion or as the fully qualified type name.

## NOTES

Filters are case-insensitive. Provider and parent filters match exactly; child filters use prefix matching unless `-ExactMatch` is specified. Results reflect the Azure resource types available from the Bicep type loader bundled with the module.

## RELATED LINKS

- [Get-BicepResourceProvider]()
- [Get-BicepResourceType]()
- [Get-BicepApiVersion]()
