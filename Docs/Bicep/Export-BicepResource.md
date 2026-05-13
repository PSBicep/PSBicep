---
document type: cmdlet
external help file: Bicep-help.xml
HelpUri: ''
Locale: en-US
Module Name: Bicep
ms.date: 05/13/2026
PlatyPS schema version: 2024-05-01
title: Export-BicepResource
---

# Export-BicepResource

## SYNOPSIS

Exports a specified Azure resource as Bicep.

## SYNTAX

### ByQueryOutStream

```
Export-BicepResource -KQLQuery <string> [-UseKQLResult] [-IncludeTargetScope]
 [-RemoveUnknownProperties] [-AsString] [-Raw] [<CommonParameters>]
```

### ByQueryOutPath

```
Export-BicepResource -KQLQuery <string> -OutputDirectory <string> [-UseKQLResult]
 [-IncludeTargetScope] [-RemoveUnknownProperties] [-Raw] [<CommonParameters>]
```

### ByIdOutStream

```
Export-BicepResource -ResourceId <string[]> [-IncludeTargetScope] [-RemoveUnknownProperties]
 [-AsString] [-Raw] [<CommonParameters>]
```

### ByIdOutPath

```
Export-BicepResource -ResourceId <string[]> -OutputDirectory <string> [-IncludeTargetScope]
 [-RemoveUnknownProperties] [-Raw] [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  None


## DESCRIPTION

Exports a specified Azure resource as Bicep.

## EXAMPLES

### Example 1

PS C:\> Export-BicepResource -ResourceId $ResourceId -Path 'C:\temp\myfile.bicep'

Exports a resource specified by resource id to the file "myfile.bicep".

### Example 2

PS C:\> Export-BicepResource -ResourceId $ResourceId -AsString

Exports a resource specified by resource id as a string.

## PARAMETERS

### -AsString

Specify that the resource will be exported as a string.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ByIdOutStream
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: ByQueryOutStream
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -IncludeTargetScope

Include the target scope in the resulting exported resource string or file.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ByIdOutStream
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: ByIdOutPath
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: ByQueryOutStream
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: ByQueryOutPath
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -KQLQuery

Query for Azure Resource Graph to select resources to export.
Must include the property id containing a resource id for each resource.

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ByQueryOutStream
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: ByQueryOutPath
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -OutputDirectory

Path to directory where output files will be saved.

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ByIdOutPath
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: ByQueryOutPath
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Raw

Output raw json without converting to bicep.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ByIdOutStream
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: ByIdOutPath
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: ByQueryOutStream
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: ByQueryOutPath
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -RemoveUnknownProperties

Will use a rewriter to strip any property not defined in the resource schema.
This can help to produce deployable templates but also has a risk of removing useful data, use with caution.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ByIdOutStream
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: ByIdOutPath
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: ByQueryOutStream
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: ByQueryOutPath
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -ResourceId

The id of the resource to export.

```yaml
Type: System.String[]
DefaultValue: None
SupportsWildcards: false
Aliases:
- id
ParameterSets:
- Name: ByIdOutStream
  Position: Named
  IsRequired: true
  ValueFromPipeline: true
  ValueFromPipelineByPropertyName: true
  ValueFromRemainingArguments: false
- Name: ByIdOutPath
  Position: Named
  IsRequired: true
  ValueFromPipeline: true
  ValueFromPipelineByPropertyName: true
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -UseKQLResult

Use resource body directly from KQL query result instead of getting the actual resource body.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ByQueryOutStream
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: ByQueryOutPath
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

Accepts a single Azure resource ID from the pipeline. The resource ID should be in the standard Azure resource ID format.

### System.String[]

Accepts an array of Azure resource IDs from the pipeline. Each resource ID should be in the standard Azure resource ID format.

## OUTPUTS

### System.Object

Returns the exported Bicep code. When -AsString is used, returns a string. When writing to files, returns the path(s) to the generated Bicep files.

## NOTES

This command requires an active Azure connection. Use Connect-Bicep before running this command. It exports Azure resources by querying Azure Resource Graph (via KQL) or by directly referencing resource IDs.

## RELATED LINKS

- [Connect-Bicep]()
- [ConvertTo-Bicep]()
- [Bicep Documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
- [PSBicep Repository](https://github.com/PSBicep/PSBicep)
