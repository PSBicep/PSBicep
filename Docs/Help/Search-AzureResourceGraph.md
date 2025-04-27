---
external help file: Bicep-help.xml
Module Name: Bicep
online version:
schema: 2.0.0
---

# Search-AzureResourceGraph

## SYNOPSIS
Search Azure Resource Graph for resources in your Azure subscriptions.

## SYNTAX

### String (Default)
```
Search-AzureResourceGraph -Query <String> [-SubscriptionId <String[]>] [-ManagementGroup <String[]>]
 [-AuthorizationScopeFilter <String>] [-AllowPartialScopes <Boolean>] [-PageSize <Int32>]
 [<CommonParameters>]
```

### Path
```
Search-AzureResourceGraph -QueryPath <String> [-SubscriptionId <String[]>] [-ManagementGroup <String[]>]
 [-AuthorizationScopeFilter <String>] [-AllowPartialScopes <Boolean>] [-PageSize <Int32>]
 [<CommonParameters>]
```

## DESCRIPTION
This cmdlet allows you to query Azure Resource Graph using either a query string or a path to a file containing the query.

## EXAMPLES

### Example 1
```
PS C:\> Search-AzureResourceGraph -Query "Resources | project name, type, location | limit 10"
```

Lists name, type and location of the first 10 resources in your Azure subscriptions.

## PARAMETERS

### -AllowPartialScopes
Allow partial scopes in the query. Only applicable for tenant and management group level queries to decide whether to allow partial scopes for result in case the number of subscriptions exceed allowed limits.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AuthorizationScopeFilter
Defines what level of authorization resources should be returned based on the which subscriptions and management groups are passed as scopes.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: AtScopeAboveAndBelow, AtScopeAndAbove, AtScopeAndBelow, AtScopeExact

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ManagementGroup
Azure management groups against which to execute the query.

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

### -PageSize
Number of records to return in each page of results. If the response is too large, the pagesize will dynamically be reduced until successful.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Query
The Azure Resource Graph query to execute.

```yaml
Type: String
Parameter Sets: String
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -QueryPath
Path to a file containing the Azure Resource Graph query to execute

```yaml
Type: String
Parameter Sets: Path
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SubscriptionId
Azure subscription IDs against which to execute the query.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable, -ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
