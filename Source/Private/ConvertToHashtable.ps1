function ConvertToHashtable {
    param(
        [object]
        $InputObject,
        [switch]
        $Ordered
    )
    if ($Ordered.IsPresent) {
        $HashTable = [ordered]@{}
    }
    else {
        $HashTable = @{}
    }
    foreach ($Prop in $InputObject.psobject.Properties) {
        if ($null -eq $Prop.Value) {
            $HashTable.Add($Prop.Name, $Prop.Value)
        }
        elseif ($Prop.TypeNameOfValue -eq 'System.String' -or $Prop.Value.GetType().IsValueType) {
            $HashTable.Add($Prop.Name, $Prop.Value)
        }
        else {
            $Value = ConvertToHashtable -InputObject $Prop.Value -Ordered:$Ordered
            $HashTable.Add($Prop.Name, $Value)
        }
    }
    $HashTable
}