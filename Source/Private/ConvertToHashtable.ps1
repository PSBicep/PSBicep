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
        if(
            $null -eq $InputObject -or 
            $InputObject.GetType().FullName -eq 'System.String' -or 
            $InputObject.GetType().IsValueType
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
                $Prop.Value.GetType().IsValueType
            ) {
                $HashTable.Add($Prop.Name, $Prop.Value)
            }
            else{
                $Value = $Prop.Value | ConvertToHashtable -Ordered:$Ordered
                $HashTable.Add($Prop.Name, $Value)
            }
        }
        return $HashTable
    }
}