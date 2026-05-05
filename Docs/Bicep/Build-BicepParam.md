---
document type: cmdlet
external help file: Bicep-help.xml
HelpUri: ''
Locale: en-US
Module Name: Bicep
ms.date: 05/08/2026
PlatyPS schema version: 2024-05-01
title: Build-BicepParam
---

# Build-BicepParam

## SYNOPSIS

Builds one or more .bicepparam files.

## SYNTAX

### Default (Default)

```
Build-BicepParam [[-Path] <string>] [[-OutputDirectory] <string>] [-ExcludeFile <string[]>]
 [-Compress] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### OutputPath

```
Build-BicepParam [[-Path] <string>] [[-OutputPath] <string>] [-ExcludeFile <string[]>] [-Compress]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

### AsHashtable

```
Build-BicepParam [[-Path] <string>] [-ExcludeFile <string[]>] [-AsHashtable] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### AsString

```
Build-BicepParam [[-Path] <string>] [-ExcludeFile <string[]>] [-AsString] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  None


## DESCRIPTION

Build-BicepParam is equivalent to the Bicep CLI command 'bicep build-params' but with some additional features.

- Compile all bicepparam files in a directory

- Output ARM Template parameters directly as string or hashtable without writing to file


Any error or warning from bicep will be written to the information stream.
To save output in a variable, use stream redirection.
See example below.

## EXAMPLES

### Example 1 Compile single bicepparam file in working directory

Build-BicepParam -Path vnet.bicep

### Compile single bicepparam file and specify the output directory

Build-BicepParam -Path 'c:\bicep\modules\vnet.bicepparam' -OutputDirectory 'c:\armtemplates\vnet.parameters.json'

### Compile all .bicepparam files in a directory

Build-BicepParam -Path 'c:\bicep\modules\'

### Compile all .bicepparam files in the working directory except vnet.bicepparam

Build-BicepParam -Path 'c:\bicep\modules\' -ExcludeFile vnet.bicepparam

### Compile a .bicepparam file and output as string

Build-BicepParam -Path '.\vnet.bicep' -AsString

### Example 7: Compile a .bicepparam file as hashtable and pass it to New-AzResourceGroupDeployment

$ParameterObject = Build-BicepParam -Path '.\vnet.bicepparam' -AsHashtable
New-AzResourceGroupDeployment -ResourceGroupName vnet-rg -TemplateObject $Template -TemplateParameterObject $ParameterObject

### Example 8: Compiles single bicepparam file and saves the output as the specified file path.

Build-BicepParam -Path 'c:\bicep\modules\vnet.bicepparam' -OutputPath 'c:\armtemplates\newvnet.parameters.json'

### Example 10: Compile a .bicep file and compress the outputted ARM Json

Build-BicepParam -Path '.\main.bicep' -Compress

## PARAMETERS

### -AsHashtable

The -AsHashtable prints all output as a hashtable instead of corresponding files.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: AsHashtable
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -AsString

The -AsString prints all output as a string instead of corresponding files.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: AsString
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Compress

Compress the built ARM Template to reduce file size

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: OutputPath
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: Default
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Confirm

Prompts you for confirmation before running the cmdlet.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases:
- cf
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

### -ExcludeFile

Specifies a .bicepparam file to exclude from compilation

```yaml
Type: System.String[]
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: OutputPath
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: AsHashtable
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: AsString
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: Default
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

Specifies the target directory where the compiled files should be created

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: Default
  Position: 2
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -OutputPath

Specify the filename of the compiled file.

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: OutputPath
  Position: 2
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Path

Specfies the path to the directory or file that should be compiled

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: OutputPath
  Position: 1
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: AsHashtable
  Position: 1
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: AsString
  Position: 1
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: Default
  Position: 1
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -WhatIf

Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases:
- wi
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

## OUTPUTS

### System.Object

Returns the compiled ARM JSON parameter file content. When -AsString is used, returns a string. When -AsHashtable is used, returns a hashtable. When writing to files, returns the path(s) to the generated files.

## NOTES

Build-BicepParam compiles .bicepparam files into ARM JSON parameter files. This is equivalent to running 'bicep build-params' from the Bicep CLI, but with additional features like directory compilation and multiple output modes.

For more information, visit the PSBicep repository: https://github.com/PSBicep/PSBicep

## RELATED LINKS

- [Build-Bicep]()
- [Bicep Documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
- [PSBicep Repository](https://github.com/PSBicep/PSBicep)
