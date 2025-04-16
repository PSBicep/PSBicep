---
external help file: Bicep-help.xml
Module Name: Bicep
online version:
schema: 2.0.0
---

# Connect-Bicep

## SYNOPSIS
Connect and sign in to Azure.

## SYNTAX

### Interactive (Default)
```
Connect-Bicep [-Tenant <String>] [-ClientId <String>] [<CommonParameters>]
```

### Certificate
```
Connect-Bicep -Tenant <String> -ClientId <String> -CertificatePath <String>
 [<CommonParameters>]
```

### ManagedIdentity
```
Connect-Bicep [-Tenant <String>] [-ClientId <String>] [-ManagedIdentity]
 [<CommonParameters>]
```

## DESCRIPTION
Used to create a connection to Azure.
Required by command Export-BicepResource but also supported by commands that rely on some kind of Azure resoruce, like for example getting or publishing modules from Azure Container Registry.

## EXAMPLES

### Example 1
```
PS C:\> Connect-Bicep
```

Creates a connection to Azure using interactive logon.

## PARAMETERS

### -CertificatePath
Path to certificate used for authentication, can be path to a file or certificate store.

```yaml
Type: String
Parameter Sets: Certificate
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ClientId
ClientId of application to connect as.

```yaml
Type: String
Parameter Sets: Interactive, ManagedIdentity
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: String
Parameter Sets: Certificate
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ManagedIdentity
Connect using Managed Identity

```yaml
Type: SwitchParameter
Parameter Sets: ManagedIdentity
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Tenant
Name or Id of Tenant to connect to.

```yaml
Type: String
Parameter Sets: Interactive, ManagedIdentity
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: String
Parameter Sets: Certificate
Aliases:

Required: True
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

### System.Object
## NOTES

## RELATED LINKS
