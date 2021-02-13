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
            $Params = @{
                MessageData = [System.Management.Automation.HostInformationMessage]@{
                    Message         = $OutputString
                    ForegroundColor = $Host.PrivateData.VerboseForegroundColor
                    BackgroundColor = $Host.PrivateData.VerboseBackgroundColor
                }
                Tag         = 'Information'
            }
        }
        'Warning' {
            $Params = @{
                MessageData = [System.Management.Automation.HostInformationMessage]@{
                    Message         = $OutputString
                    ForegroundColor = $Host.PrivateData.WarningForegroundColor
                    BackgroundColor = $Host.PrivateData.WarningBackgroundColor
                }
                Tag         = 'Warning'
            }
        }
        'Error' {
            $Params = @{
                MessageData = [System.Management.Automation.HostInformationMessage]@{
                    Message         = $OutputString
                    ForegroundColor = $Host.PrivateData.ErrorForegroundColor
                    BackgroundColor = $Host.PrivateData.ErrorBackgroundColor
                }
                Tag         = 'Error'
            }
        }
    }
    
    Write-Information @Params -InformationAction 'Continue'
    return ($Diagnostic.Level -ne [Bicep.Core.Diagnostics.DiagnosticLevel]::Error)
}