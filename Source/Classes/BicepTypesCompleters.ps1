class BicepResourceProviderCompleter : System.Management.Automation.IArgumentCompleter{
    [System.Collections.Generic.IEnumerable[System.Management.Automation.CompletionResult]] CompleteArgument(
        [string] $CommandName,
        [string] $ParameterName,
        [string] $wordToComplete,
        [System.Management.Automation.Language.CommandAst] $CommandAst,
        [Collections.IDictionary] $fakeBoundParameters
    )
    {
        [array]$ResourceProviders = (GetBicepTypes).ResourceProvider | Where-Object { $_ -like "$wordToComplete*" } | Sort-Object -Unique
        
        $list = [System.Collections.Generic.List[System.Management.Automation.CompletionResult]]::new()
        
        foreach ($ResourceProvider in $ResourceProviders) {
            $CompletionText = $ResourceProvider
            $ListItemText   = $ResourceProvider
            $ResultType     = [System.Management.Automation.CompletionResultType]::ParameterValue
            $ToolTip        = $ResourceProvider
  
            $obj = [System.Management.Automation.CompletionResult]::new($CompletionText, $ListItemText, $ResultType, $Tooltip)
            $list.add($obj)
        }

        return $list
        
    }
 }

 class BicepResourceCompleter : System.Management.Automation.IArgumentCompleter{
    [System.Collections.Generic.IEnumerable[System.Management.Automation.CompletionResult]] CompleteArgument(
        [string] $CommandName,
        [string] $ParameterName,
        [string] $wordToComplete,
        [System.Management.Automation.Language.CommandAst] $CommandAst,
        [Collections.IDictionary] $fakeBoundParameters
    )
    {
        if ($fakeBoundParameters.ContainsKey('ResourceProvider')) {
            [array]$Resources = GetBicepTypes | Where-Object {
                $_.ResourceProvider -eq $fakeBoundParameters.ResourceProvider -and 
                $_.Resource -like "$wordToComplete*"
            } | Select-Object -ExpandProperty Resource -Unique | Sort-Object
        }
        else {
            [array]$Resources = (GetBicepTypes).Resource | Where-Object { $_ -like "$wordToComplete*" } | Sort-Object -Unique
        }
        
        $list = [System.Collections.Generic.List[System.Management.Automation.CompletionResult]]::new()
        
        foreach ($Resource in $Resources) {
            $CompletionText = $Resource
            $ListItemText   = $Resource
            $ResultType     = [System.Management.Automation.CompletionResultType]::ParameterValue
            
            $ToolTip = '{0}/{1}' -f $fakeBoundParameters.ResourceProvider, $Resource
            $ToolTip = $ToolTip.TrimEnd('/')
  
            $obj = [System.Management.Automation.CompletionResult]::new($CompletionText, $ListItemText, $ResultType, $Tooltip)
            $list.add($obj)
        }

        return $list
        
    }
 }

 class BicepResourceChildCompleter : System.Management.Automation.IArgumentCompleter{
    [System.Collections.Generic.IEnumerable[System.Management.Automation.CompletionResult]] CompleteArgument(
        [string] $CommandName,
        [string] $ParameterName,
        [string] $wordToComplete,
        [System.Management.Automation.Language.CommandAst] $CommandAst,
        [Collections.IDictionary] $fakeBoundParameters
    )
    {
        if ($fakeBoundParameters.ContainsKey('ResourceProvider') -and $fakeBoundParameters.ContainsKey('Resource')) {
            $Children = GetBicepTypes | Where-Object {
                $_.ResourceProvider -eq $fakeBoundParameters.ResourceProvider -and 
                $_.Resource -eq $fakeBoundParameters.Resource -and 
                $fakeBoundParameters.Child -like "$wordToComplete*"
            } | Select-Object -ExpandProperty Child -Unique | Sort-Object
        }
        else {
            $Children = (GetBicepTypes).Child | Where-Object { $_ -like "$wordToComplete*" } | Sort-Object -Unique -Descending
        }
        
        $list = [System.Collections.Generic.List[System.Management.Automation.CompletionResult]]::new()
        
        foreach ($Child in $Children) {
            $CompletionText = $Child
            $ListItemText   = $Child
            $ResultType     = [System.Management.Automation.CompletionResultType]::ParameterValue
            
            $ToolTip = '{0}/{1}/{2}' -f $fakeBoundParameters.ResourceProvider, $fakeBoundParameters.Resource, $Child
            $ToolTip = $ToolTip.TrimEnd('/')
  
            $obj = [System.Management.Automation.CompletionResult]::new($CompletionText, $ListItemText, $ResultType, $Tooltip)
            $list.add($obj)
        }

        return $list
        
    }
 }

 class BicepResourceApiVersionCompleter : System.Management.Automation.IArgumentCompleter{
    [System.Collections.Generic.IEnumerable[System.Management.Automation.CompletionResult]] CompleteArgument(
        [string] $CommandName,
        [string] $ParameterName,
        [string] $wordToComplete,
        [System.Management.Automation.Language.CommandAst] $CommandAst,
        [Collections.IDictionary] $fakeBoundParameters
    )
    {
        if ($fakeBoundParameters.ContainsKey('ResourceProvider') -and $fakeBoundParameters.ContainsKey('Resource')) {
            $ApiVersions = GetBicepTypes | Where-Object {
                $_.ResourceProvider -eq $fakeBoundParameters.ResourceProvider -and 
                $_.Resource -eq $fakeBoundParameters.Resource -and 
                $fakeBoundParameters.ApiVersion -like "$wordToComplete*"
            } | Select-Object -ExpandProperty ApiVersion -Unique | Sort-Object -Descending
        }
        elseif ($fakeBoundParameters.ContainsKey('ResourceProvider') -and $fakeBoundParameters.ContainsKey('Resource') -and $fakeBoundParameters.ContainsKey('Child')) {
            $ApiVersions = GetBicepTypes | Where-Object {
                $_.ResourceProvider -eq $fakeBoundParameters.ResourceProvider -and 
                $_.Resource -eq $fakeBoundParameters.Resource -and
                $_.Child -eq $fakeBoundParameters.Child -and 
                $fakeBoundParameters.ApiVersion -like "$wordToComplete*"
            } | Select-Object -ExpandProperty ApiVersion -Unique | Sort-Object -Descending
        }
        else {
            $ApiVersions = (GetBicepTypes).ApiVersion | Where-Object { $_ -like "$wordToComplete*" } | Sort-Object -Unique -Descending
        }
        
        $list = [System.Collections.Generic.List[System.Management.Automation.CompletionResult]]::new()
        
        foreach ($ApiVersion in $ApiVersions) {
            $CompletionText = $ApiVersion
            $ListItemText   = $ApiVersion
            $ResultType     = [System.Management.Automation.CompletionResultType]::ParameterValue
            
            $ToolTip = '{0}/{1}/{2}' -f $fakeBoundParameters.ResourceProvider, $fakeBoundParameters.Resource, $fakeBoundParameters.Child
            $ToolTip = $ToolTip.TrimEnd('/') + "@$ApiVersion"
            
            $obj = [System.Management.Automation.CompletionResult]::new($CompletionText, $ListItemText, $ResultType, $Tooltip)
            $list.add($obj)
        }

        return $list
        
    }
 }

 class BicepTypeCompleter : System.Management.Automation.IArgumentCompleter{
    [System.Collections.Generic.IEnumerable[System.Management.Automation.CompletionResult]] CompleteArgument(
        [string] $CommandName,
        [string] $ParameterName,
        [string] $wordToComplete,
        [System.Management.Automation.Language.CommandAst] $CommandAst,
        [Collections.IDictionary] $fakeBoundParameters
    )
    {
        $Types = (GetBicepTypes).FullName | Where-Object { $_ -like "$wordToComplete*" } | Sort-Object -Unique -Descending
        
        $list = [System.Collections.Generic.List[System.Management.Automation.CompletionResult]]::new()
        
        foreach ($Type in $Types) {
            $CompletionText = $Type
            $ListItemText   = $Type
            $ResultType     = [System.Management.Automation.CompletionResultType]::ParameterValue
            $ToolTip        = $Type
  
            $obj = [System.Management.Automation.CompletionResult]::new($CompletionText, $ListItemText, $ResultType, $Tooltip)
            $list.add($obj)
        }

        return $list
        
    }
 }