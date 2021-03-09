---
external help file: Bicep-help.xml
Module Name: Bicep
online version:
schema: 2.0.0
---

# Get-BicepApiReference

## SYNOPSIS
Get ARM Template reference docs for provided resource type.

## SYNTAX

### Type (Default)
```powershell
Get-BicepApiReference [[-Type] <String>] [-Force] [<CommonParameters>]
```

### ResourceProvider
```powershell
Get-BicepApiReference -ResourceProvider <String> -Resource <String> [-Child <String>] [-ApiVersion <String>]
 [-Force] [<CommonParameters>]
```

## DESCRIPTION
**Get-BicepApiReference** is a command to find and open the ARM template reference documentation in a browser for the provided resource type.

## EXAMPLES

### Example 1: Get ARM template reference documentation using the Bicep types format
```powershell
Get-BicepApiReference -Type 'Microsoft.Network/virtualNetworks@2020-06-01'
```

This will open the documentation for the `Microsoft.Network` resource provider, resource `virtualNetworks` and API Version `2020-06-01` in a browser.

### Example 2: Get the latest ARM template reference for a resource type
```powershell
Get-BicepApiReference -ResourceProvider Microsoft.Storage -Resource storageAccounts
```

This will open the documentation for the `Microsoft.Storage` resource provider, resource `storageAccounts` using the latest API Version in a browser.

### Example 3: Get the ARM template reference for a resource type using a specific API Version
```powershell
Get-BicepApiReference -ResourceProvider Microsoft.Storage -Resource storageAccounts -ApiVersion 2018-11-01
```

This will open the documentation for the `Microsoft.Storage` resource provider, resource `storageAccounts` using the ´2018-11-01` API Version in a browser.

### Example 3: Get the ARM template reference for a child resource
```powershell
Get-BicepApiReference -ResourceProvider Microsoft.Compute -Resource virtualMachines -Child extensions
```

This will open the documentation for the `Microsoft.Compute` resource provider, resource `virtualMachines/extensions`


## PARAMETERS

### -ApiVersion
Specifies the Api Version to use. If no API Version is provided the latest will be used.

```yaml
Type: String
Parameter Sets: ResourceProvider
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Child
Can be used to specify which child resource to get the docs for.

```yaml
Type: String
Parameter Sets: ResourceProvider
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
Use this parameter to try to force open docs that can't be found.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: Please

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Resource
Specify which resource from a resource provider to get the docs for.

```yaml
Type: String
Parameter Sets: ResourceProvider
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ResourceProvider
Specifies which Resource Provider to get the docs for.

```yaml
Type: String
Parameter Sets: ResourceProvider
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Type
Use -Type to find docs using the Bicep types format used when defining a resource in a Bicep template.

```yaml
Type: String
Parameter Sets: TypeString
Aliases:

Required: False
Position: 0
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
