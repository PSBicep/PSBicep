---
external help file: Bicep-help.xml
Module Name: Bicep
online version:
schema: 2.0.0
---

# New-BicepMarkdownDocumentation

## SYNOPSIS
Create markdown documentation for bicep files

## SYNTAX

### FromFile (Default)
```
New-BicepMarkdownDocumentation [[-File] <String>] [-Console] [-Force]
 [<CommonParameters>]
```

### FromFolder
```
New-BicepMarkdownDocumentation [[-Path] <String>] [-Recurse] [-Console] [-Force]
 [<CommonParameters>]
```

## DESCRIPTION
This command creates a basic markdown documentation of one or more bicep files.

## EXAMPLES

### Example 1
```powershell
PS C:\> New-BicepMarkdownDocumentation -File C:\MyBicepFile.bicep
```

This command will create a file called `c:\MyBicepFile.md` containing basic documentation.

### Example 2
```powershell
PS C:\> New-BicepMarkdownDocumentation -Path C:\MyBicepFiles\ -Verbose -Recurse
```

This command will traverse the c:\MyBicepFiles\ folder, including subfolders, and create documentation for all bicep files. The markdown files will be saved with the same name as the bicep files, using .md file extension.

## PARAMETERS

### -Console
Output the resulting markdown to to the cosole as string.

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

### -File
Bicep file to create documentation from

```yaml
Type: String
Parameter Sets: FromFile
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
NOT IMPLEMENTED!

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

### -Path
Path to folder containing bicep files. All files in folder will have markdown documentation created.

```yaml
Type: String
Parameter Sets: FromFolder
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Recurse
Search recursively for .bicep files.

```yaml
Type: SwitchParameter
Parameter Sets: FromFolder
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable, -ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### File or string

## NOTES

## RELATED LINKS
