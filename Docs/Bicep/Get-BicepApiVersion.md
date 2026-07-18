---
document type: cmdlet
external help file: PSBicep.dll-Help.xml
HelpUri: ''
Locale: en-US
Module Name: Bicep
ms.date: 07/18/2026
PlatyPS schema version: 2024-05-01
title: Get-BicepApiVersion
---

# Get-BicepApiVersion

## SYNOPSIS

Retrieve the API version for a Bicep resource type.

## SYNTAX

### __AllParameterSets

```
Get-BicepApiVersion -ResourceType <string> [-Skip <int>] [-AvoidPreview] [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  None


## DESCRIPTION

Retrieve the API version for a specified Bicep resource type. This command helps identify which API versions are available for a given resource, allowing you to target specific or latest API versions in your Bicep templates.

## EXAMPLES

### Example 1

Get the API version for the Microsoft.Compute/virtualMachines resource type.

## PARAMETERS

### -AvoidPreview

When specified, excludes preview API versions from the results, returning only stable/general availability (GA) versions.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: ''
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

### -ResourceType

The Bicep resource type to get the API version for (e.g., Microsoft.Compute/virtualMachines).

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: true
  ValueFromPipeline: true
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Skip

The number of results to skip.
Useful for pagination when there are many API versions available.

```yaml
Type: System.Int32
DefaultValue: ''
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

The Bicep resource type string to retrieve API versions for. Accepts pipeline input.

## OUTPUTS

### System.String

Returns the API version information as an object.

## NOTES

This command retrieves available API versions for a Bicep resource type. Use -AvoidPreview to filter out preview versions.

## RELATED LINKS

- [Bicep Documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
- [Azure Resource Manager Template Reference](https://learn.microsoft.com/azure/azure-resource-manager/templates/template-reference)
