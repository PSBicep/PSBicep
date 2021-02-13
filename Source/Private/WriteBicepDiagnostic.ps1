function WriteBicepDiagnostic {
    [CmdletBinding()]
    param (
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
}