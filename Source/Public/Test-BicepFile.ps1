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
            if($IgnoreDiagnosticOutput) {
                $null = ParseBicep @ParseParams *>&1
            }
            else {
                $null = ParseBicep @ParseParams
            }
        }
        catch {
            # We don't care about errors here.
        }

        $DiagnosticGroups = $DiagnosticOutput | Group-Object -Property { $_.Tags[0] }
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
                foreach($Group in $DiagnosticGroups) {
                    $List = foreach($Entry in $Group.Group) {
                        @{
                            Message = $Entry.MessageData.Message
                            Source = $Entry.Source
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