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
            $FullVersion = Get-BicepNetVersion -Verbose:$false
            Write-Verbose -Message "Using Bicep version: $FullVersion"
        }
    }

    process {
        $File = Get-Item -Path $Path
        
        if ($File) {
            $BuildResult = Build-BicepNetFile -Path $file.FullName
            $ARMTemplate = $BuildResult.Template[0]

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
