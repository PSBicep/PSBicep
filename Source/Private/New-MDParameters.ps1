function New-MDParameters {
    [CmdletBinding()]
    param(
        [object]$Parameters
    )

    if ($null -eq $Parameters) {
        return 'n/a'
    }

    $ParameterNames = ($Parameters | Get-Member -MemberType NoteProperty).Name
    $MDParameters = New-MDTableHeader -Headers 'Name', 'Type', 'AllowedValues', 'Metadata'

    foreach ($Parameter in $ParameterNames) {
        $Param = $Parameters.$Parameter
        $MDParameters += "| $Parameter | $($Param.type) | $(
            if ($Param.allowedValues) {
                forEach ($value in $Param.allowedValues) {
                    "$value <br/>"
                }
            } else {
                "n/a"
            }
            ) | $(
            forEach ($item in $Param.metadata) {
                    $res = $item.PSObject.members | Where-Object { $_.MemberType -eq 'NoteProperty' }
                    
                    if ($null -ne $res) {
                    
                        $res.Name + ': ' + $res.Value + '<br/>'
                    
                    }
            }) |`n" 
    }

    $MDParameters
}