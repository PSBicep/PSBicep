function ConvertToHashtable {
    param(
        [Parameter(ValueFromPipeline)]
        [object]
        $InputObject,
        [switch]
        $Ordered
    )
    process {
 
        # If InputObject is string or valuetype, don't recurse, just return the value.
        if (
            $null -eq $InputObject -or 
            $InputObject.GetType().FullName -eq 'System.String' -or 
            $InputObject.GetType().IsValueType -or
            $InputObject -is [System.Collections.Specialized.OrderedDictionary] -or
            $InputObject -is [System.Collections.Hashtable]
        ) {
            return $InputObject
        }
 
        # Else,  create a hashtable and loop over properties.
        if ($Ordered.IsPresent) {
            $HashTable = [ordered]@{}
        }
        else {
            $HashTable = @{}
        }
        foreach ($Prop in $InputObject.psobject.Properties) {
            if (
                $null -eq $Prop.Value -or 
                $Prop.TypeNameOfValue -eq 'System.String' -or 
                $Prop.Value.GetType().IsValueType -or
                $InputObject -is [System.Collections.Specialized.OrderedDictionary] -or
                $InputObject -is [System.Collections.Hashtable]
            ) {
                $HashTable.Add($Prop.Name, $Prop.Value)
            }
            else {
                if ($Prop.TypeNameOfValue -eq 'System.Object[]' -and (-not $Prop.Value)) {
                    $Value = @()
                }
                elseif ($Prop.TypeNameOfValue -eq 'System.Object[]' -and $Prop.Value) {
                    $Value = @($Prop.Value)
                }
                else {
                    $Value = $Prop.Value | ConvertToHashtable -Ordered:$Ordered
                }
                $HashTable.Add($Prop.Name, $Value)
            }
        }
        return $HashTable
    }
}