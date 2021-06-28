function New-BicepParameterFile {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, Position = 1)]
        [string]$Path,

        [Parameter(Position = 2)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("All", "Required")]
        [string]$Parameters,        

        [Parameter(Position = 3)]
        [ValidateNotNullOrEmpty()]
        [string]$OutputDirectory
    )

    begin {
        if (-not $Script:ModuleVersionChecked) {
            TestModuleVersion
        }
        if ($PSBoundParameters.ContainsKey('OutputDirectory') -and (-not (Test-Path $OutputDirectory))) {
            $null = New-Item $OutputDirectory -Force -ItemType Directory -WhatIf:$WhatIfPreference
        }

        if ($VerbosePreference -eq [System.Management.Automation.ActionPreference]::Continue) {
            $DLLPath = [Bicep.Core.Workspaces.Workspace].Assembly.Location
            $DLLFile = Get-Item -Path $DLLPath
            $FullVersion = $DLLFile.VersionInfo.ProductVersion.Split('+')[0]
            Write-Verbose -Message "Using Bicep version: $FullVersion"
        }
    }

    process {
        $File = Get-Item -Path $Path
        
        if ($File) {
            $ARMTemplate = ParseBicep -Path $File.FullName -IgnoreDiagnostics

            if($PSBoundParameters.ContainsKey('OutputDirectory')) {
                $OutputFilePath = Join-Path -Path $OutputDirectory -ChildPath ('{0}.parameters.json' -f $File.BaseName)
            }
            else {
                $OutputFilePath = $File.FullName -replace '\.bicep','.parameters.json'
            }
            if (!$PSBoundParameters.ContainsKey('Parameters')){
                $Parameters='Required'
            }
             GenerateParameterFile -Content $ARMTemplate -Parameters $Parameters -DestinationPath $OutputFilePath -WhatIf:$WhatIfPreference
        }
        else {
            Write-Error "No bicep file named $Path was found!"
        }
    }
}
