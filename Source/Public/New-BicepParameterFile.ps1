function New-BicepParameterFile {
    [CmdletBinding(DefaultParameterSetName = 'Default',
                   SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ParameterSetName = 'Default', Position = 1)]
        [Parameter(Mandatory, ParameterSetName = 'AsString', Position = 1)]
        [Parameter(Mandatory, ParameterSetName = 'AsHashtable', Position = 1)]
        [string]$TemplateFile,

        [Parameter(ParameterSetName = 'Default', Position = 2)]
        [ValidateNotNullOrEmpty()]
        [string]$OutputDirectory
    )

    begin {
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
        $File = Get-Item -Path $TemplateFile
        if ($File) {
            $ARMTemplate = ParseBicep -Path $File.FullName

            if ($PSBoundParameters.ContainsKey('OutputDirectory')) {
                $OutputFilePath = Join-Path -Path $OutputDirectory -ChildPath ('{0}.parameters.json' -f $File.BaseName)
            }
            else {
                $OutputFilePath = $File.FullName -replace '\.bicep','.parameters.json'
            }

            GenerateParameterFile -Content $ARMTemplate -DestinationPath $OutputFilePath -WhatIf:$WhatIfPreference
        }
        else {
            Write-Error "No bicep file named $Path was found!"
        }
    }
}