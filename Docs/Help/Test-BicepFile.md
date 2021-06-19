---
external help file: Bicep-help.xml
Module Name: Bicep
online version:
schema: 2.0.0
---

# Test-BicepFile

## SYNOPSIS
Tests if a bicep file is valid.

## SYNTAX

```
Test-BicepFile [-Path] <String> [[-OutputType] <String>] [[-AcceptDiagnosticLevel] <DiagnosticLevel>]
 [-IgnoreDiagnosticOutput] [<CommonParameters>]
```

## DESCRIPTION
Tests if a bicep file is valid. Returns true/false by default, but can
be made to return JSON output.

## EXAMPLES

### Example 1
```powershell
PS C:\> Test-BicepFile -Path 'MyBicep.bicep'
```

Returns true if the bicep file has no errors or warnings.

### Example 2
```powershell
PS C:\> Test-BicepFile -Path 'MyBicep.bicep' -AcceptDiagnosticLevel 'Warning'
```

Returns true if the bicep file has no errors.

## PARAMETERS

### -AcceptDiagnosticLevel
Set the highest level of diagnostic output that will be accepted
for the test to pass. Setting Warning here will make a bicep file
with errors fail the test while a bicep files with warnings will be
tested valid.

Settings this to Error will accept anything. Since this is not a wanted
scenario the command will throw an error.

```yaml
Type: DiagnosticLevel
Parameter Sets: (All)
Aliases:
Accepted values: Off, Info, Warning, Error

Required: False
Position: 2
Default value: Info
Accept pipeline input: False
Accept wildcard characters: False
```

### -IgnoreDiagnosticOutput
Will run silently, not outputing any diagnostic information 
to the information stream.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutputType
Set format for output. Simple will only return true or false.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Simple, Json

Required: False
Position: 1
Default value: Simple
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
Path to a bicep file to test.

```yaml
Type: String
Parameter Sets: (All)
Aliases: PSPath

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
