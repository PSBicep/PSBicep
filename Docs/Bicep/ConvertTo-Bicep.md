---
document type: cmdlet
external help file: Bicep-help.xml
HelpUri: ''
Locale: en-US
Module Name: Bicep
ms.date: 05-11-2026
PlatyPS schema version: 2024-05-01
title: ConvertTo-Bicep
---

# ConvertTo-Bicep

## SYNOPSIS

Decompile ARM templates to .bicep files

## SYNTAX

### Decompile (Default)

```
ConvertTo-Bicep [-Path <string>] [-OutputDirectory <string>] [-AsString] [-Force]
 [<CommonParameters>]
```

### ConvertFromBodyHash

```
ConvertTo-Bicep [-IncludeTargetScope] [-ConfigurationPath <string>]
 [-ResourceDictionary <hashtable>] [-RemoveUnknownProperties] [<CommonParameters>]
```

### ConvertFromBody

```
ConvertTo-Bicep -ResourceId <string> -ResourceBody <string> [-IncludeTargetScope]
 [-ConfigurationPath <string>] [-RemoveUnknownProperties] [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  None


## DESCRIPTION

ConvertTo-Bicep is equivalent to 'bicep decompile' but with some additional features.

-Decompile all ARM templates in a directory -Specify output directory

## EXAMPLES

### Decompile single json file in working directory

ConvertTo-Bicep -Path vnet.json

### Decompile all ARM template json files in the provided directory

ConvertTo-Bicep -Path 'c:\armtemplates\'

### Decompile single json file in working directory

ConvertTo-Bicep -Path vnet.json -OutputDirectory 'c:\bicep\modules\'

### Decompile single json file and output as a string

ConvertTo-Bicep -Path vnet.json -AsString

## PARAMETERS

### -AsString

-AsString prints all output as a string instead of corresponding files.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: Decompile
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -ConfigurationPath

Path to a bicepconfig.json file for specifying formatting and compilation options during decompilation.

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ConvertFromBodyHash
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: ConvertFromBody
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

Force overwriting of output files.
If the output.bicep file already exists and -Force is not set we will not overwrite the resulting file.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: Decompile
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

When specified, includes the targetScope declaration in the generated Bicep file.
This is useful when converting ARM templates that have a specific target scope defined.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ConvertFromBodyHash
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: ConvertFromBody
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -OutputDirectory

Specifies the path to the directory where the compiled files should be outputted

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: Decompile
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Path

Specfies the path to the directory or file that should be decompiled

```yaml
Type: System.String
DefaultValue: $pwd.path
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: Decompile
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
- Name: ConvertFromBodyHash
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: ConvertFromBody
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -ResourceBody

A JSON representation of a resource

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ConvertFromBody
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -ResourceDictionary

A hashtable with resource id as key and resource body as value.

```yaml
Type: System.Collections.Hashtable
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ConvertFromBodyHash
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

Resource id of the resource.

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ConvertFromBody
  Position: Named
  IsRequired: true
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

Outputs bicep template as string if the -AsString parameter is used, else it will write the template to a file.

## NOTES

Go to module repository https://github.com/PSBicep/PSBicep for detailed info, reporting issues and to submit contributions.

## RELATED LINKS

- [Convert-JsonToBicep]()
- [Export-BicepResource]()
- [Bicep Documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
- [PSBicep Repository](https://github.com/PSBicep/PSBicep)
