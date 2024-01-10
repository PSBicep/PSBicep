function NewMDModules {
    [CmdletBinding()]
    param(
        [object[]]$Modules
    )

    if (-not $Modules -or $Modules.Count -eq 0) {
        return 'n/a'
    }

    $MDModules = NewMDTableHeader -Headers 'Name', 'Path'

    foreach ($Module in $Modules) {
        $MDModules += "| $($Module.Name) | $($Module.Path) |`n"
    }

    $MDModules
}