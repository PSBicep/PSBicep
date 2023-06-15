---
external help file: Bicep-help.xml
Module Name: Bicep
online version:
schema: 2.0.0
---

# Build-BicepParam

## SYNOPSIS
Builds one or more .bicepparam files.

## SYNTAX

### Default (Default)
```powershell
Build-BicepParam [[-Path] <String>] [[-OutputDirectory] <String>] [-ExcludeFile <String[]>] [-Compress]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

### OutputPath
```powershell
Build-BicepParam [[-Path] <String>] [[-OutputPath] <String>] [-ExcludeFile <String[]>] [-Compress] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

### AsHashtable
```powershell
Build-BicepParam [[-Path] <String>] [-ExcludeFile <String[]>] [-AsHashtable] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### AsString
```powershell
Build-BicepParam [[-Path] <String>] [-ExcludeFile <String[]>] [-AsString] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
**Build-BicepParam** is equivalent to the Bicep CLI command 'bicep build-params' but with some additional features.

- Compile all bicepparam files in a directory  
- Output ARM Template parameters directly as string or hashtable without writing to file  

Any error or warning from bicep will be written to the information stream.
To save output in a variable, use stream redirection. See example below.

## EXAMPLES

### Example 1 Compile single bicepparam file in working directory
```powershell
Build-BicepParam -Path vnet.bicep
```

### Example 2: Compile single bicepparam file and specify the output directory
```powershell
Build-BicepParam -Path 'c:\bicep\modules\vnet.bicepparam' -OutputDirectory 'c:\armtemplates\vnet.parameters.json'
```

### Example 3: Compile all .bicepparam files in a directory
```powershell
Build-BicepParam -Path 'c:\bicep\modules\'
```

### Example 4: Compile all .bicepparam files in the working directory except vnet.bicepparam
```powershell
Build-BicepParam -Path 'c:\bicep\modules\' -ExcludeFile vnet.bicepparam
```

### Example 5: Compile a .bicepparam file and output as string
```powershell
Build-BicepParam -Path '.\vnet.bicep' -AsString
```

### Example 7: Compile a .bicepparam file as hashtable and pass it to New-AzResourceGroupDeployment
```powershell
$ParameterObject = Build-BicepParam -Path '.\vnet.bicepparam' -AsHashtable
New-AzResourceGroupDeployment -ResourceGroupName vnet-rg -TemplateObject $Template -TemplateParameterObject $ParameterObject
```

### Example 8: Compiles single bicepparam file and saves the output as the specified file path.
```powershell
Build-BicepParam -Path 'c:\bicep\modules\vnet.bicepparam' -OutputPath 'c:\armtemplates\newvnet.parameters.json'
```

### Example 10: Compile a .bicep file and compress the outputted ARM Json
```powershell
Build-BicepParam -Path '.\main.bicep' -Compress
```

## PARAMETERS

### -AsHashtable
The -AsHashtable prints all output as a hashtable instead of corresponding files.

```yaml
Type: SwitchParameter
Parameter Sets: AsHashtable
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AsString
The -AsString prints all output as a string instead of corresponding files.

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

### -Compress
Compress the built ARM Template to reduce file size

```yaml
Type: SwitchParameter
Parameter Sets: Default, OutputPath
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

### -ExcludeFile
Specifies a .bicepparam file to exclude from compilation

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutputDirectory
Specifies the target directory where the compiled files should be created

```yaml
Type: String
Parameter Sets: Default
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutputPath
Specify the filename of the compiled file.

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
Specfies the path to the directory or file that should be compiled

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
