function NewMDMetadata {
    [CmdletBinding()]
    param(
        [object]$Metadata
    )

    if ($null -eq $Metadata) {
        return 'n/a'
    }

    $MetadataNames = ($Metadata | Get-Member -MemberType NoteProperty).Name | Where-Object {$_ -NotLike '_*'}
    $MDMetadata = NewMDTableHeader -Headers 'Name', 'Value'

    foreach ($var in $MetadataNames) {
        $Param = $Metadata.$var
        if ($Param.GetType().Name -eq 'PSCustomObject') {
            $tempArr = @()
            $tempObj = ($Param | Get-Member -MemberType NoteProperty).Name
            foreach ($item in $tempObj) {
                $tempArr += $item + ': ' + $Param.$($item) + '<br/>'
            }
            $MDMetadata += "| $var | $tempArr |`n"
        }
        else {
            $MDMetadata += "| $var | $Param |`n"
        }
        
    }

    $MDMetadata = $MDMetadata -replace ', ', '<br/>'

    $MDMetadata
}