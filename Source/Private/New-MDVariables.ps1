function New-MDVariables {
    [CmdletBinding()]
    param(
        [object]$Variables
    )

    if ($null -eq $Variables) {
        return 'n/a'
    }

    $VariableNames = ($Variables | Get-Member -MemberType NoteProperty).Name
    $MDVariables = New-MDTableHeader -Headers 'Name', 'Value'

    foreach ($var in $VariableNames) {
        $Param = $Variables.$var
        $MDVariables += "| $var | $Param |`n"
    }

    $MDVariables
}