class BicepVersionCompleter : System.Management.Automation.IArgumentCompleter{
    [System.Collections.Generic.IEnumerable[System.Management.Automation.CompletionResult]] CompleteArgument(
        [string] $CommandName,
        [string] $ParameterName,
        [string] $wordToComplete,
        [System.Management.Automation.Language.CommandAst] $CommandAst,
        [Collections.IDictionary] $fakeBoundParameters
    )
    {
        [array]$BicepVersions = (ListBicepVersions) | Where-Object { $_ -like "$wordToComplete*" }
        
        $list = [System.Collections.Generic.List[System.Management.Automation.CompletionResult]]::new()
        
        foreach ($BicepVersion in $BicepVersions) {
            $CompletionText = $BicepVersion
            $ListItemText   = $BicepVersion
            $ResultType     = [System.Management.Automation.CompletionResultType]::ParameterValue
            $ToolTip        = $BicepVersion
  
            $obj = [System.Management.Automation.CompletionResult]::new($CompletionText, $ListItemText, $ResultType, $Tooltip)
            $list.add($obj)
        }

        return $list
        
    }
 }

