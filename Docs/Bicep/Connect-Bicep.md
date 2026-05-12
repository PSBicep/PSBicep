---
document type: cmdlet
external help file: Bicep-help.xml
HelpUri: ''
Locale: en-US
Module Name: Bicep
ms.date: 05-11-2026
PlatyPS schema version: 2024-05-01
title: Connect-Bicep
---

# Connect-Bicep

## SYNOPSIS

Connect and sign in to Azure.

## SYNTAX

### Interactive (Default)

```
Connect-Bicep [-Tenant <string>] [-ClientId <string>] [-ManagementEndpoint <Object>]
 [<CommonParameters>]
```

### ClientSecret

```
Connect-Bicep -Tenant <string> -ClientId <string> -ClientSecret <string>
 [-ManagementEndpoint <Object>] [<CommonParameters>]
```

### Certificate

```
Connect-Bicep -Tenant <string> -ClientId <string> -CertificatePath <string>
 [-ManagementEndpoint <Object>] [<CommonParameters>]
```

### ManagedIdentity

```
Connect-Bicep -ManagedIdentity [-Tenant <string>] [-ClientId <string>]
 [-ManagementEndpoint <Object>] [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  None


## DESCRIPTION

Used to create a connection to Azure.
Required by command Export-BicepResource but also supported by commands that rely on some kind of Azure resource, like for example getting or publishing modules from Azure Container Registry.

## EXAMPLES

### Example 1

PS C:\> Connect-Bicep

Creates a connection to Azure using interactive logon.

## PARAMETERS

### -CertificatePath

Path to certificate used for authentication, can be path to a file or certificate store.

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: Certificate
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -ClientId

ClientId of application to connect as.

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ClientSecret
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: Certificate
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: Interactive
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: ManagedIdentity
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -ClientSecret

The client secret for secret-based authentication.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ClientSecret
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -ManagedIdentity

Connect using Managed Identity

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ManagedIdentity
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -ManagementEndpoint

The Azure management endpoint URL.
Defaults to `https://management.azure.com`.

```yaml
Type: System.Object
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ClientSecret
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: Certificate
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: Interactive
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: ManagedIdentity
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Tenant

Name or Id of Tenant to connect to.

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ClientSecret
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: Certificate
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: Interactive
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: ManagedIdentity
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

Returns $true if the connection was successful, $false otherwise.

## NOTES

This command establishes an authenticated connection to Azure for use with Bicep commands. It supports multiple authentication methods:
- **Interactive**: Uses browser-based authentication (default)
- **ManagedIdentity**: Uses Azure Managed Identity
- **Certificate**: Uses a certificate for authentication
- **ClientSecret**: Uses client ID and secret for authentication

The authentication tokens are stored in module-scoped variables and used by subsequent Bicep commands that require Azure access.

## RELATED LINKS

- [Disconnect-Bicep]()
- [Azure Authentication](https://learn.microsoft.com/azure/azure-resource-manager/authenticate-powershell)
