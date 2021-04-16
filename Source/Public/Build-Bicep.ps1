function Build-Bicep {
    [CmdletBinding(DefaultParameterSetName = 'Default',
        SupportsShouldProcess)]
    [Alias('Invoke-BicepBuild')]
    param (
        [Parameter(ParameterSetName = 'Default', Position = 1)]
        [Parameter(ParameterSetName = 'AsString', Position = 1)]
        [Parameter(ParameterSetName = 'AsHashtable', Position = 1)]
        [string]$Path = $pwd.path,

        [Parameter(ParameterSetName = 'Default', Position = 2)]
        [ValidateNotNullOrEmpty()]
        [string]$OutputDirectory,

        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'AsString')]
        [Parameter(ParameterSetName = 'AsHashtable')]
        [string[]]$ExcludeFile,

        [Parameter(ParameterSetName = 'Default')]
        [switch]$GenerateParameterFile,

        [Parameter(ParameterSetName = 'AsString')]
        [switch]$AsString,

        [Parameter(ParameterSetName = 'AsHashtable')]
        [switch]$AsHashtable
    )

    

    begin {
        if (-not $Script:ModuleVersionChecked) {
            testModuleVersion
        }
        if ($PSBoundParameters.ContainsKey('OutputDirectory') -and (-not (Test-Path $OutputDirectory))) {
            $null = New-Item $OutputDirectory -Force -ItemType Directory -WhatIf:$WhatIfPreference
        }
        if ($VerbosePreference -eq [System.Management.Automation.ActionPreference]::Continue) {
            $DLLPath = [Bicep.Core.Workspaces.Workspace].Assembly.Location
            $DllFile = Get-Item -Path $DLLPath
            $FullVersion = $DllFile.VersionInfo.ProductVersion.Split('+')[0]
            Write-Verbose -Message "Using Bicep version: $FullVersion"
        }
    }

    process {
        $files = Get-Childitem -Path $Path *.bicep -File
        if ($files) {
            foreach ($file in $files) {
                if ($file.Name -notin $ExcludeFile) {
                    $ARMTemplate = ParseBicep -Path $file.FullName
                    if (-not [string]::IsNullOrWhiteSpace($ARMTemplate)) {
                        $BicepModuleVersion = (Get-Module -Name Bicep).Version | Sort-Object -Descending | Select-Object -First 1
                        $ARMTemplateObject = ConvertFrom-Json -InputObject $ARMTemplate
                        $ARMTemplateObject.metadata._generator.name += " (Bicep PowerShell $BicepModuleVersion)"
                        $ARMTemplate = ConvertTo-Json -InputObject $ARMTemplateObject -Depth 100
                        if ($AsString.IsPresent) {
                            Write-Output $ARMTemplate
                        }
                        elseif ($AsHashtable.IsPresent) {
                            $ARMTemplate | ConvertFrom-Json -AsHashtable
                        }
                        else {        
                            if ($PSBoundParameters.ContainsKey('OutputDirectory')) {
                                $OutputFilePath = Join-Path -Path $OutputDirectory -ChildPath ('{0}.json' -f $file.BaseName)
                                $ParameterFilePath = Join-Path -Path $OutputDirectory -ChildPath ('{0}.parameters.json' -f $file.BaseName)
                            }
                            else {
                                $OutputFilePath = $file.FullName -replace '\.bicep', '.json'
                                $ParameterFilePath = $file.FullName -replace '\.bicep', '.parameters.json'
                            }
                            $null = Out-File -Path $OutputFilePath -InputObject $ARMTemplate -Encoding utf8 -WhatIf:$WhatIfPreference
                            if ($GenerateParameterFile.IsPresent) {
                                GenerateParameterFile -Content $ARMTemplate -DestinationPath $ParameterFilePath -WhatIf:$WhatIfPreference
                            }
                        }
                    }
                }
            }
        }
        else {
            Write-Host "No bicep files located in path $Path"
        }
    }
}