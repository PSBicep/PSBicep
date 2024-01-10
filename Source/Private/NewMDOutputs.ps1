function NewMDOutputs {
    [CmdletBinding()]
    param(
        [object]$Outputs
    )

    if ($null -eq $Outputs) {
        return 'n/a'
    }

    $OutputNames = ($Outputs | Get-Member -MemberType NoteProperty).Name
    $MDOutputs = NewMDTableHeader -Headers 'Name', 'Type', 'Value'

    foreach ($OutputName in $OutputNames) {
        $OutputValues = $Outputs.$OutputName
        $MDOutputs += "| $OutputName | $($OutputValues.type) | $($OutputValues.value) |`n"
    }

    $MDOutputs
}