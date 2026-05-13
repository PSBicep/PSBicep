---
document type: cmdlet
external help file: Bicep-help.xml
HelpUri: ''
Locale: en-US
Module Name: Bicep
ms.date: 05/13/2026
PlatyPS schema version: 2024-05-01
title: Build-Bicep
---

# Build-Bicep

## SYNOPSIS

Builds one or more .bicep files.

## SYNTAX

### Default (Default)

```
Build-Bicep [[-Path] <string>] [[-OutputDirectory] <string>] [-ExcludeFile <string[]>]
 [-GenerateAllParametersFile] [-GenerateRequiredParametersFile] [-NoRestore] [-Compress] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

### OutputPath

```
Build-Bicep [[-Path] <string>] [[-OutputPath] <string>] [-ExcludeFile <string[]>]
 [-GenerateAllParametersFile] [-GenerateRequiredParametersFile] [-NoRestore] [-Compress] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

### AsHashtable

```
Build-Bicep [[-Path] <string>] [-ExcludeFile <string[]>] [-AsHashtable] [-NoRestore] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

### AsString

```
Build-Bicep [[-Path] <string>] [-ExcludeFile <string[]>] [-AsString] [-NoRestore] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  Invoke-BicepBuild


## DESCRIPTION

Build-Bicep is equivalent to the Bicep CLI command 'bicep build' but with some additional features.

- Compile all files in a directory

- Generate ARM Template Parameter files

- Output ARM Template directly as string or hashtable without writing to file


Any error or warning from bicep will be written to the information stream.
To save output in a variable, use stream redirection.
See example below.

## EXAMPLES

### Compile single bicep file in working directory

Build-Bicep -Path vnet.bicep

### Compile single bicep file and specify the output directory

Build-Bicep -Path 'c:\bicep\modules\vnet.bicep' -OutputDirectory 'c:\armtemplates\vnet.json'

### Compile all .bicep files in a directory

Build-Bicep -Path 'c:\bicep\modules\'

### Compile all .bicep files in the working directory except vnet.bicep

Build-Bicep -Path 'c:\bicep\modules\' -ExcludeFile vnet.bicep

### Compile a .bicep file and output as string

Build-Bicep -Path '.\vnet.bicep' -AsString

### Compile a .bicep files in the working directory and generate a parameter file with all parameters

Build-Bicep -Path '.\vnet.bicep' -GenerateAllParametersFile

### Compile a .bicep file as hashtable and pass it to New-AzResourceGroupDeployment

$Template=Build-Bicep -Path '.\vnet.bicep' -AsHashtable
New-AzResourceGroupDeployment -ResourceGroupName vnet-rg -TemplateObject $Template

### Compiles single bicep file and saves the output as the specified file path.

Build-Bicep -Path 'c:\bicep\modules\vnet.bicep' -OutputPath 'c:\armtemplates\newvnet.json'

### Compile a .bicep file without restoring dependant modules

Build-Bicep -Path '.\main.bicep' -NoRestore

### Compile a .bicep file and compress the outputted ARM Json

Build-Bicep -Path '.\main.bicep' -Compress

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

Specifies a .bicep file to exclude from compilation

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

### -GenerateAllParametersFile

Generate an ARM template parameter file with all parameters from the bicep file.

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

### -GenerateRequiredParametersFile

Generate an ARM template parameter file with the required parameters from the bicep file.

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

### -NoRestore

Skips trying to restore dependent modules

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

Specify the filename of the generated ARM template.

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
DefaultValue: $pwd.path
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

Runs the command in a mode that only reports what would happen without performing the actions.

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

Returns the compiled ARM template as JSON files in the output directory, or as a string/hashtable when using -AsString or -AsHashtable. Also generates parameter files when -GenerateRequiredParametersFile or -GenerateAllParametersFile is specified.

## NOTES

Go to module repository https://github.com/PSBicep/PSBicep for detailed info, reporting issues and to submit contributions.

## RELATED LINKS

- [Build-BicepParam]()
- [Bicep Documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
- [PSBicep Repository](https://github.com/PSBicep/PSBicep)
