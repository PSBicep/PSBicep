function New-MDTableHeader {
    [CmdletBinding()]
    param(
        [string[]]$Headers
    )

    if (-not $Headers -or $Headers.Count -eq 0) {
        throw 'Headers cannot be empty!'
    }

    $r = '|'
    foreach ($Head in $Headers) {
        $r += " $Head |"
    }
    
    $r = "$r`n|"
    
    1..($Headers.Count) | ForEach-Object {
        $r += "----|"
    }

    $r = "$r`n"
    
    $r
}