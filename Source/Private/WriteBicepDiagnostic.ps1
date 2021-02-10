function WriteBicepDiagnostic {
    [CmdletBinding()]
    param (
        [Bicep.Core.Diagnostics.Diagnostic]$Diagnostic
    )
        
    New-Alias -Name 'Write-Info' -Value 'Write-Host' -Option Private -WhatIf:$false -Confirm:$false

    $Level = $Diagnostic.Level.ToString()
    $Code = $Diagnostic.Code.ToString()
    $Message = $Diagnostic.Message.ToString()
    $OutputString = "'$Path : $Level ${Code}: $Message'"

    & "Write-$($Diagnostic.Level)" $OutputString

    Remove-Alias -Name 'Write-Info'
}