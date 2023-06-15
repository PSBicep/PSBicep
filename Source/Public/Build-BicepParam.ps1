function Build-BicepParam {
    [CmdletBinding(DefaultParameterSetName = 'Default',
        SupportsShouldProcess)]
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

        [Parameter(ParameterSetName = 'AsString')]
        [switch]$AsString,

        [Parameter(ParameterSetName = 'AsHashtable')]
        [switch]$AsHashtable,

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
        if ($PSBoundParameters.ContainsKey('OutputPath') -and (-not (Test-Path $OutputPath)) -and -not [string]::IsNullOrEmpty((Split-Path -Path $OutputPath))) {
            $null = New-Item (Split-Path -Path $OutputPath) -Force -ItemType Directory -WhatIf:$WhatIfPreference
        }
        if ($PSBoundParameters.ContainsKey('OutputPath') -and ((Split-path -path $Path -leaf) -notmatch "\.bicepparam$")) { 
            Write-Error 'If -Path and -OutputPath parameters are used, only one .bicepparam file can be used as input to -Path. E.g. -Path "C:\Output\template.bicepparm" -OutputPath "C:\Output\template.parameters.json".'
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

                    $ARMTemplate = Build-BicepNetParamFile -Path $file.FullName -NoRestore:$NoRestore.IsPresent

                    if (-not [string]::IsNullOrWhiteSpace($ARMTemplate)) {
                        if ($AsString.IsPresent) {
                            Write-Output $ARMTemplate
                        }
                        elseif ($AsHashtable.IsPresent) {
                            $ARMTemplateObject | ConvertToHashtable -Ordered
                        }
                        else {        
                            if ($PSBoundParameters.ContainsKey('OutputPath')) {
                                $OutputFilePath = $OutputPath
                            }
                            elseif ($PSBoundParameters.ContainsKey('OutputDirectory')) {
                                $OutputFilePath = Join-Path -Path $OutputDirectory -ChildPath ('{0}.parameters.json' -f $file.BaseName)                         
                            }
                            else {
                                $OutputFilePath = $file.FullName -replace '\.bicepparam', '.parameters.json'
                            }
                            if ($Compress.IsPresent) {
                                $ARMTemplate = $ARMTemplate | ConvertFrom-Json | ConvertTo-Json -Depth 100 -Compress
                            }
                            $null = Out-File -Path $OutputFilePath -InputObject $ARMTemplate -Encoding utf8 -WhatIf:$WhatIfPreference
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