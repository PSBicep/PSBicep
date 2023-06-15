---
external help file: Bicep-help.xml
Module Name: Bicep
online version:
schema: 2.0.0
---

# Format-BicepFile

## SYNOPSIS

Format one or several Bicep files.

## SYNTAX

### Default (Default)

```powershell
Format-BicepFile [[-Path] <String>] [[-NewlineOption] <String>] [[-IndentKindOption] <String>]
 [[-IndentSize] <Int32>] [-InsertFinalNewline] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### OutputPath

```powershell
Format-BicepFile [[-Path] <String>] [[-OutputPath] <String>] [[-NewlineOption] <String>]
 [[-IndentKindOption] <String>] [[-IndentSize] <Int32>] [-InsertFinalNewline] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### OutputDirectory

```powershell
Format-BicepFile [[-Path] <String>] [[-OutputDirectory] <String>] [[-NewlineOption] <String>]
 [[-IndentKindOption] <String>] [[-IndentSize] <Int32>] [-InsertFinalNewline] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### AsString

```powershell
Format-BicepFile [[-Path] <String>] [[-NewlineOption] <String>] [[-IndentKindOption] <String>]
 [[-IndentSize] <Int32>] [-InsertFinalNewline] [-AsString] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

Format one or several Bicep files.

## EXAMPLES

### Example 1

```powershell
PS C:\> Format-BicepFile -Path $BicepTemplate
```

Formats a Bicep file.

### Example 2

```powershell
PS C:\> Format-BicepFile -Path $Directory -OutputDirectory $OtherDir
```

Formats all Bicep files in a folder and outputs the result as other files in another folder.

## PARAMETERS

### -AsString

Outputs the Bicep file(s) as string instead of files.

```yaml
Type: SwitchParameter
Parameter Sets: AsString
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm

Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IndentKindOption

The kind of indentation, spaces or tabs.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IndentSize

The size of indentation.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -InsertFinalNewline

Whether or not to insert a final new line in the formatted file(s).

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

### -NewlineOption

The newline type for the file.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutputDirectory

The directory to output files to.

```yaml
Type: String
Parameter Sets: OutputDirectory
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutputPath

The path to output the file to.

```yaml
Type: String
Parameter Sets: OutputPath
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path

The path to the file or directory of files to format.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf

Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
