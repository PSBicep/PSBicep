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
        if ($PSBoundParameters.ContainsKey('OutputDirectory') -and (-not (Test-Path $OutputDirectory))) {
            $null = New-Item $OutputDirectory -Force -ItemType Directory -WhatIf:$WhatIfPreference
        }
    }

    process {
        $File = Get-Item -Path $Path
        $validateBicepFile = Test-BicepFile -Path $File.FullName -AcceptDiagnosticLevel Warning -IgnoreDiagnosticOutput
        if (-not $validateBicepFile) {
            Write-Error -Message "$($File.FullName) have build errors, make sure that the Bicep template builds successfully and try again."
            Write-Host "`nYou can use either 'Test-BicepFile' or 'Build-Bicep' to verify that the template builds successfully.`n"
            break
        }
        if ($File) {
            $ARMTemplate = Build-BicepFile -Path $file.FullName

            if($PSBoundParameters.ContainsKey('OutputDirectory')) {
                $OutputFilePath = Join-Path -Path $OutputDirectory -ChildPath ('{0}.parameters.json' -f $File.BaseName)
            }
            else {
                $OutputFilePath = $File.FullName -replace '\.bicep','.parameters.json'
            }
            if (-not $PSBoundParameters.ContainsKey('Parameters')){
                $Parameters='Required'
            }
            GenerateParameterFile -Content $ARMTemplate -Parameters $Parameters -DestinationPath $OutputFilePath -WhatIf:$WhatIfPreference
        }
        else {
            Write-Error "No bicep file named $Path was found!"
        }
    }
}