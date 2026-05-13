---
document type: cmdlet
external help file: Bicep-help.xml
HelpUri: ''
Locale: en-US
Module Name: Bicep
ms.date: 05/13/2026
PlatyPS schema version: 2024-05-01
title: Test-BicepFile
---

# Test-BicepFile

## SYNOPSIS

Tests if a bicep or bicepparam file is valid.

## SYNTAX

### __AllParameterSets

```
Test-BicepFile [-Path] <string> [[-OutputType] <string>]
 [[-AcceptDiagnosticLevel] <BicepDiagnosticLevel>] [-IgnoreDiagnosticOutput] [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  None


## DESCRIPTION

Tests if a bicep file is valid.
Returns true/false by default, but can be made to return JSON output.

## EXAMPLES

### Example 1

PS C:\> Test-BicepFile -Path 'MyBicep.bicep'

Returns true if the bicep file has no errors or warnings.

### Example 2

PS C:\> Test-BicepFile -Path 'MyBicep.bicep' -AcceptDiagnosticLevel 'Warning'

Returns true if the bicep file has no errors.

## PARAMETERS

### -AcceptDiagnosticLevel

Set the highest level of diagnostic output that will be accepted for the test to pass.
Setting Warning here will make a bicep file with errors fail the test while a bicep files with warnings will be tested valid.

Settings this to Error will accept anything.
Since this is not a wanted scenario the command will throw an error.

```yaml
Type: BicepDiagnosticLevel
DefaultValue: Info
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 2
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -IgnoreDiagnosticOutput

Will run silently, not outputting any diagnostic information  to the information stream.

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

### -OutputType

Set format for output.
Simple will only return true or false.

```yaml
Type: System.String
DefaultValue: Simple
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 1
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Path

Path to a bicep file to test.

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases:
- PSPath
ParameterSets:
- Name: (All)
  Position: 0
  IsRequired: true
  ValueFromPipeline: true
  ValueFromPipelineByPropertyName: true
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

Specifies the path to a bicep or bicepparam file to test.

## OUTPUTS

### System.Object

Returns $true or $false if the test passes or fails (Simple mode), or a JSON string with diagnostic information (Json mode).

## NOTES

## RELATED LINKS

- [Build-Bicep]()
