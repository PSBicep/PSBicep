function New-MDModules {
    [CmdletBinding()]
    param(
        [object[]]$Modules
    )

    if (-not $Modules -or $Modules.Count -eq 0) {
        return 'n/a'
    }

    $MDModules = New-MDTableHeader -Headers 'Name', 'Path'

    foreach ($Module in $Modules) {
        $MDModules += "| $($Module.Name) | $($Module.Path) |`n"
    }

    $MDModules
}