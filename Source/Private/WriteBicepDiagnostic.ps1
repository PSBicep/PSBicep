function WriteBicepDiagnostic {
    [CmdletBinding()]
    param (
<<<<<<< HEAD
        [Bicep.Core.Diagnostics.Diagnostic]$Diagnostic,

        [Bicep.Core.Syntax.SyntaxTree]$SyntaxTree
    )
    
    $FileUri = $SyntaxTree.FileUri
    $LocalPath = $FileUri.LocalPath
    $LineStarts = $SyntaxTree.LineStarts

    $Position = [Bicep.Core.Text.TextCoordinateConverter]::GetPosition($LineStarts, $Diagnostic.Span.Position)
    [int]$Line = $Position.Item1 + 1
    [int]$Character = $Position.Item2 + 1

    $Level = $Diagnostic.Level.ToString()
    $Code = $Diagnostic.Code
    $Message = $Diagnostic.Message
    $OutputString = "$LocalPath(${Line},$Character) : $Level ${Code}: $Message"

    switch ($Diagnostic.Level) {
        'Info' {
            Write-Host "ERROR: $OutputString"
        }
        'Warning' {
            Write-Warning $OutputString
        }
        'Error' {
            WriteErrorStream $OutputString
        }
    }

    return ($Diagnostic.Level -eq [Bicep.Core.Diagnostics.DiagnosticLevel]::Error)
=======
        [Bicep.Core.Diagnostics.Diagnostic]$Diagnostic
    )
        
    New-Alias -Name 'Write-Info' -Value 'Write-Host' -Option Private -WhatIf:$false -Confirm:$false

    $Level = $Diagnostic.Level.ToString()
    $Code = $Diagnostic.Code.ToString()
    $Message = $Diagnostic.Message.ToString()
    $OutputString = "'$Path : $Level ${Code}: $Message'"

    & "Write-$($Diagnostic.Level)" $OutputString

    Remove-Alias -Name 'Write-Info'
>>>>>>> e462783dcd30f382baa0191b3b4a95ad490188a7
}