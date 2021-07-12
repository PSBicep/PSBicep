# TODO This won't work with BicepNet, has to be rewritten.
function Test-BicepFile {
    [CmdletBinding()]
    param (
        # Specifies a path to one or more locations.
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias("PSPath")]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path,

        # Set output type
        [Parameter()]
        [ValidateSet('Simple', 'Json')]
        [String]
        $OutputType = 'Simple',

        # Level of diagnostic that will fail the test
        [Parameter()]
        [BicepDiagnosticLevel]
        $AcceptDiagnosticLevel = [BicepDiagnosticLevel]::Info,


        # Write diagnostic output to screen
        [Parameter()]
        [switch]
        $IgnoreDiagnosticOutput
    )
    
    begin {
        if (-not $Script:ModuleVersionChecked) {
            TestModuleVersion
        }

        if ($VerbosePreference -eq [System.Management.Automation.ActionPreference]::Continue) {
            $FullVersion = Get-BicepNetVersion -Verbose:$false
            Write-Verbose -Message "Using Bicep version: $FullVersion"
        }

        if ($AcceptDiagnosticLevel -eq [BicepDiagnosticLevel]::Error) {
            throw 'Accepting diagnostic level Error results in test never failing.'
        }
    }
    
    process {
        $file = Get-Item -Path $Path
        try {
            $ParseParams = @{
                Path                = $file.FullName 
                InformationVariable = 'DiagnosticOutput' 
                ErrorAction         = 'Stop'
            }
            $BuildResult = Build-BicepNetFile -Path $file.FullName

            if (-not $IgnoreDiagnosticOutput) {
                $BuildResult.Diagnostic | WriteBicepNetDiagnostic -InformationAction 'Continue'
            }
            
        }
        catch {
            # We don't care about errors here.
        }

        $DiagnosticGroups = $BuildResult.Diagnostic | Group-Object -Property { $_.Level }
        $HighestDiagLevel = $null
        foreach ($DiagGroup in $DiagnosticGroups) {
            $Level = [int][BicepDiagnosticLevel]$DiagGroup.Name
            if ($Level -gt $HighestDiagLevel) {
                $HighestDiagLevel = $Level
            }
        }

        switch ($OutputType) {
            'Simple' {
                if ([int]$AcceptDiagnosticLevel -ge $HighestDiagLevel) {
                    return $true
                }
                else {
                    return $false
                }
            }
            'Json' {
                $Result = @{}
                foreach ($Group in $DiagnosticGroups) {
                    $List = foreach ($Entry in $Group.Group) {
                        @{
                            Path      = $Entry.LocalPath
                            Line      = [int]$Entry.Position[0] + 1
                            Character = [int]$Entry.Position[1] + 1
                            Level     = $Entry.Level.ToString()
                            Code      = $Entry.Code
                            Message   = $Entry.Message
                        }
                    }
                    $Result[$Group.Name] = @($List)
                }
                return $Result | ConvertTo-Json -Depth 5
            }
            default {
                # this should never happen but just to make sure
                throw "$_ has not been implemented yet."
            }
        }
    }

}