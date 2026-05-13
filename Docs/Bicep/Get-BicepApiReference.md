---
document type: cmdlet
external help file: Bicep-help.xml
HelpUri: ''
Locale: en-US
Module Name: Bicep
ms.date: 05/13/2026
PlatyPS schema version: 2024-05-01
title: Get-BicepApiReference
---

# Get-BicepApiReference

## SYNOPSIS

Get ARM Template reference docs for provided resource type.

## SYNTAX

### TypeString (Default)

```
Get-BicepApiReference [[-Type] <string>] [-Latest] [-Force] [-ReturnUri] [<CommonParameters>]
```

### ResourceProvider

```
Get-BicepApiReference -ResourceProvider <string> -Resource <string> [-Child <string>]
 [-ApiVersion <string>] [-Force] [-ReturnUri] [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  None


## DESCRIPTION

Get-BicepApiReference is a command to find and open the ARM template reference documentation in a browser for the provided resource type.

## EXAMPLES

### Get ARM template reference documentation using the Bicep types format

Get-BicepApiReference -Type 'Microsoft.Network/virtualNetworks@2020-06-01'

This will open the documentation for the `Microsoft.Network` resource provider, resource `virtualNetworks` and API Version `2020-06-01` in a browser.

### Get the latest ARM template reference for a resource type

Get-BicepApiReference -ResourceProvider Microsoft.Storage -Resource storageAccounts

This will open the documentation for the `Microsoft.Storage` resource provider, resource `storageAccounts` using the latest API Version in a browser.

### Get the ARM template reference for a resource type using a specific API Version

Get-BicepApiReference -ResourceProvider Microsoft.Storage -Resource storageAccounts -ApiVersion 2018-11-01

This will open the documentation for the `Microsoft.Storage` resource provider, resource `storageAccounts` using the `2018-11-01` API Version in a browser.

### Get the ARM template reference for a child resource

Get-BicepApiReference -ResourceProvider Microsoft.Compute -Resource virtualMachines -Child extensions

This will open the documentation for the `Microsoft.Compute` resource provider, resource `virtualMachines/extensions`

### Get the latest ARM template reference documentation using the Bicep types format

Get-BicepApiReference -Type 'Microsoft.Network/virtualNetworks@2020-06-01' -Latest

This will open the documentation for the `Microsoft.Network` resource provider, resource `virtualNetworks` and use the latest API Version instead of the provided version `2020-06-01`.

## PARAMETERS

### -ApiVersion

Specifies the Api Version to use.
If no API Version is provided the latest will be used.

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ResourceProvider
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Child

Can be used to specify which child resource to get the docs for.

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ResourceProvider
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Force

Use this parameter to try to force open docs that can't be found.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases:
- Please
ParameterSets:
- Name: TypeString
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: ResourceProvider
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Latest

Open the latest API version when using the types information.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: TypeString
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

Specify which resource from a resource provider to get the docs for.

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ResourceProvider
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -ResourceProvider

Specifies which Resource Provider to get the docs for.

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ResourceProvider
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -ReturnUri

If set, the command will output the api documentation URI instead of opening a browser.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: TypeString
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: ResourceProvider
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Type

Use -Type to find docs using the Bicep types format used when defining a resource in a Bicep template.

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: TypeString
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

### System.Object

Returns the documentation URI as a string when -ReturnUri is used. Otherwise, opens the documentation page in the default web browser.

## NOTES

This command constructs and returns the URL to the official Microsoft Azure documentation for a specific Bicep resource type. It supports looking up by resource provider components or by a complete type string.

## RELATED LINKS

- [Get-BicepApiVersion]()
- [Bicep Documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
- [Azure Resource Manager Template Reference](https://learn.microsoft.com/azure/azure-resource-manager/templates/template-reference)
- [PSBicep Repository](https://github.com/PSBicep/PSBicep)
