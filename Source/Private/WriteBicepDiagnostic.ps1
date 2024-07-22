function WriteBicepDiagnostic {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [BicepDiagnosticEntry[]]
        $Diagnostic
    )
    
    process {
        foreach($DiagnosticEntry in $Diagnostic) {
            $LocalPath = $DiagnosticEntry.LocalPath

            [int]$Line = $DiagnosticEntry.Position[0] + 1
            [int]$Character = $DiagnosticEntry.Position[1] + 1

            $Level = $DiagnosticEntry.Level.ToString()
            $Code = $DiagnosticEntry.Code
            $Message = $DiagnosticEntry.Message
            $OutputString = "$LocalPath(${Line},$Character) : $Level ${Code}: $Message"

            switch ($Level) {
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
        
            Write-Information @Params
        }
    }
}