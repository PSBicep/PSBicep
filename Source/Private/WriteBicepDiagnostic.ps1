function WriteBicepDiagnostic {
    [CmdletBinding()]
    param (
        [Bicep.Core.Diagnostics.Diagnostic]$Diagnostic,

        [Bicep.Core.Syntax.SyntaxTree]$SyntaxTree
    )
    Write-Warning 'WriteBicepDiagnostic does not work anymore, I''m sorry'
    return
    
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
        'Off' {
            $Params = @{
                MessageData = [System.Management.Automation.HostInformationMessage]@{
                    Message         = $OutputString
                    ForegroundColor = $Host.PrivateData.VerboseForegroundColor
                    BackgroundColor = $Host.PrivateData.VerboseBackgroundColor
                }
                Tag         = 'Off'
            }
        }
        default {
            Write-Warning "Unhandled diagnostic level: $_"
        }
    }

    return $Params
}