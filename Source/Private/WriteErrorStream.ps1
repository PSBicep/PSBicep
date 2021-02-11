function WriteErrorStream {
    [CmdletBinding()]
    param (
        [string]$String
    )
    if ($Host.Name -eq 'ConsoleHost') {
        [Console]::Error.WriteLine($String)
    }
    else {
        $Host.UI.WriteErrorLine($String)
    }
}