function Build-Bicep {
    [CmdletBinding(DefaultParameterSetName = 'Default',
        SupportsShouldProcess)]
    [Alias('Invoke-BicepBuild')]
    param (
        [Parameter(ParameterSetName = 'Default', Position = 1)]
        [Parameter(ParameterSetName = 'AsString', Position = 1)]
        [Parameter(ParameterSetName = 'AsHashtable', Position = 1)]
        [Parameter(ParameterSetName = 'OutputPath', Position = 1)]
        [string]$Path = $pwd.path,

        [Parameter(ParameterSetName = 'Default', Position = 2)]
        [ValidateNotNullOrEmpty()]
        [string]$OutputDirectory,

        [Parameter(ParameterSetName = 'OutputPath', Position = 2)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript(
            {
                (Split-path -path $_ -leaf) -match "\.json$"
            }
            , ErrorMessage = 'OutputPath needs to be a .JSON-file, e.g. "C:\Output\template.json"')]
        [string]$OutputPath,

        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'AsString')]
        [Parameter(ParameterSetName = 'AsHashtable')]
        [Parameter(ParameterSetName = 'OutputPath')]
        [string[]]$ExcludeFile,

        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'OutputPath')]
        [switch]$GenerateAllParametersFile,

        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'OutputPath')]
        [switch]$GenerateRequiredParametersFile,

        [Parameter(ParameterSetName = 'AsString')]
        [switch]$AsString,

        [Parameter(ParameterSetName = 'AsHashtable')]
        [switch]$AsHashtable,

        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'AsString')]
        [Parameter(ParameterSetName = 'AsHashtable')]
        [Parameter(ParameterSetName = 'OutputPath')]
        [switch]$NoRestore,

        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'OutputPath')]
        [switch]$Compress
    )

    begin {
        if (-not $Script:ModuleVersionChecked) {
            TestModuleVersion
        }
        if ($PSBoundParameters.ContainsKey('OutputDirectory') -and (-not (Test-Path $OutputDirectory))) {
            $null = New-Item $OutputDirectory -Force -ItemType Directory -WhatIf:$WhatIfPreference
        }
        if ($PSBoundParameters.ContainsKey('OutputPath') -and (-not (Test-Path $OutputPath))) {
            $null = New-Item (Split-Path -Path $OutputPath) -Force -ItemType Directory -WhatIf:$WhatIfPreference
        }
        if ($PSBoundParameters.ContainsKey('OutputPath') -and ((Split-path -path $Path -leaf) -notmatch "\.bicep$")) { 
            Write-Error 'If -Path and -OutputPath parameters are used, only one .bicep file can be used as input to -Path. E.g. -Path "C:\Output\template.bicep" -OutputPath "C:\Output\newtemplate.json".'
            Break
        }
        if ($VerbosePreference -eq [System.Management.Automation.ActionPreference]::Continue) {
            $FullVersion = Get-BicepNetVersion -Verbose:$false
            Write-Verbose -Message "Using Bicep version: $FullVersion"
        }
    }

    process {
        $files = Get-Childitem -Path $Path *.bicep -File
        if ($files) {
            foreach ($file in $files) {
                if ($file.Name -notin $ExcludeFile) {
                    if ($VerbosePreference -eq [System.Management.Automation.ActionPreference]::Continue) {
                        $bicepConfig= Get-BicepConfig -Path $file
                        Write-Verbose -Message "Using Bicep configuration: $($bicepConfig.Path)"
                    }
                    $ARMTemplate = Build-BicepNetFile -Path $file.FullName -NoRestore:$NoRestore.IsPresent

                    if (-not [string]::IsNullOrWhiteSpace($ARMTemplate)) {
                        $BicepModuleVersion = Get-Module -Name Bicep | Sort-Object -Descending | Select-Object -First 1
                        $ARMTemplateObject = ConvertFrom-Json -InputObject $ARMTemplate
                        if (-not [string]::IsNullOrWhiteSpace($BicepModuleVersion.PrivateData.Values.Prerelease)) {
                            $ARMTemplateObject.metadata._generator.name += " (Bicep PowerShell $($BicepModuleVersion.Version)-$($BicepModuleVersion.PrivateData.Values.Prerelease))"
                        }
                        else {
                            $ARMTemplateObject.metadata._generator.name += " (Bicep PowerShell $($BicepModuleVersion.Version))"
                        }
                        $ARMTemplate = ConvertTo-Json -InputObject $ARMTemplateObject -Depth 100
                        if ($AsString.IsPresent) {
                            Write-Output $ARMTemplate
                        }
                        elseif ($AsHashtable.IsPresent) {
                            $ARMTemplateObject | ConvertToHashtable -Ordered
                        }
                        else {        
                            if ($PSBoundParameters.ContainsKey('OutputPath')) {
                                $OutputFilePath = $OutputPath
                                $ParameterFilePath = Join-Path -Path (Split-Path -Path $OutputPath) -ChildPath ('{0}.parameters.json' -f (Split-Path -Path $OutputPath -Leaf).Split(".")[0])
                            }
                            elseif ($PSBoundParameters.ContainsKey('OutputDirectory')) {
                                $OutputFilePath = Join-Path -Path $OutputDirectory -ChildPath ('{0}.json' -f $file.BaseName)
                                $ParameterFilePath = Join-Path -Path $OutputDirectory -ChildPath ('{0}.parameters.json' -f $file.BaseName)
                            }
                            else {
                                $OutputFilePath = $file.FullName -replace '\.bicep', '.json'
                                $ParameterFilePath = $file.FullName -replace '\.bicep', '.parameters.json'
                            }
                            if ($Compress.IsPresent) {
                                $compressedARMTemplate= $ARMTemplate | ConvertFrom-Json | ConvertTo-Json -Depth 100 -Compress
                                $null = Out-File -Path $OutputFilePath -InputObject $compressedARMTemplate -Encoding utf8 -WhatIf:$WhatIfPreference
                            } else {
                                $null = Out-File -Path $OutputFilePath -InputObject $ARMTemplate -Encoding utf8 -WhatIf:$WhatIfPreference
                            }
                            if ($GenerateRequiredParametersFile.IsPresent -and $GenerateAllParametersFile.IsPresent) {
                                $parameterType = 'All'                                    
                                Write-Warning "Both -GenerateAllParametersFile and -GenerateRequiredParametersFile is present. A parameter file with all parameters will be generated."
                            }
                            elseif ($GenerateRequiredParametersFile.IsPresent) {
                                $parameterType = 'Required'
                            }
                            elseif ($GenerateAllParametersFile.IsPresent) {
                                $parameterType = 'All'
                            }

                            if ($GenerateAllParametersFile.IsPresent -or $GenerateRequiredParametersFile.IsPresent) {                                
                                GenerateParameterFile -Content $ARMTemplate -DestinationPath $ParameterFilePath -Parameters $parameterType -WhatIf:$WhatIfPreference
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