function Build-BicepParameterFile {
    [CmdletBinding(DefaultParameterSetName = 'Default',
                   SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ParameterSetName = 'Default', Position = 1)]
        [Parameter(Mandatory, ParameterSetName = 'AsString', Position = 1)]
        [Parameter(Mandatory, ParameterSetName = 'AsHashtable', Position = 1)]
        [string]$Path,

        [Parameter(ParameterSetName = 'Default', Position = 2)]
        [ValidateNotNullOrEmpty()]
        [string]$OutputDirectory,

        [Parameter(ParameterSetName = 'AsString')]
        [switch]$AsString,

        [Parameter(ParameterSetName = 'AsHashtable')]
        [switch]$AsHashtable
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
        $File = Get-Item -Path $Path
        if ($File) {
            $ARMTemplate = ParseBicep -Path $File.FullName

            if($PSBoundParameters.ContainsKey('OutputDirectory')) {
                $OutputFilePath = Join-Path -Path $OutputDirectory -ChildPath ('{0}.parameters.json' -f $File.BaseName)
            }
            else {
                $OutputFilePath = $File.FullName -replace '\.bicep','.parameters.json'
            }

            if (-not [string]::IsNullOrWhiteSpace($ARMTemplate)) {
                $ARMTemplateObject = $ARMTemplate | ConvertFrom-Json | Select-Object -Property '$schema',contentVersion,@{
                    Name = 'parameters'
                    Expression = { $_.Variables }
                }
                if ($null -eq $ARMTemplateObject.parameters) {
                    Write-Error "No parameters found in bicep file $($File.FullName)"
                }
                else {
                    foreach ($Param in $ARMTemplateObject.parameters.psobject.Properties.Name) {
                        $ARMTemplateObject.parameters.$Param = [pscustomobject]@{
                            value = $ARMTemplateObject.parameters.$Param
                        }
                    }
                    $ARMParameterTemplate = $ARMTemplateObject | ConvertTo-Json -Depth 100
                    if ($AsString.IsPresent) {
                        Write-Output $ARMParameterTemplate
                    }
                    elseif ($AsHashtable.IsPresent) {
                        Write-Output (ConvertFrom-Json -InputObject $ARMParameterTemplate -AsHashtable)
                    }
                    else {
                        $null = Out-File -Path $OutputFilePath -InputObject $ARMParameterTemplate -Encoding utf8 -WhatIf:$WhatIfPreference
                    }
                }
            }
        }
        else {
            Write-Error "No bicep file named $Path was found!"
        }
    }
}
