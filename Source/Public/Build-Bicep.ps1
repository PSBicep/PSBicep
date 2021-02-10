function Build-Bicep {
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [Alias('Invoke-BicepBuild')]
    param (
        [Parameter(ParameterSetName = 'Default',Position=1)]
        [Parameter(ParameterSetName = 'AsString',Position=1)]
        [string]$Path = $pwd.path,

        [Parameter(ParameterSetName = 'Default',Position=2)]
        [Parameter(ParameterSetName = 'AsString',Position=2)]
        [ValidateNotNullOrEmpty()]
        [string]$OutputDirectory,

        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'AsString')]
        [string[]]$ExcludeFile,

        [Parameter(ParameterSetName = 'Default')]
        [switch]$GenerateParameterFile,

        [Parameter(ParameterSetName = 'AsString')]
        [switch]$AsString
    )

    begin {
        if ($PSBoundParameters.ContainsKey('OutputDirectory') -and (-not (Test-Path $OutputDirectory))) {
            $null = New-Item $OutputDirectory -Force -ItemType Directory
        }
    }

    process {
        $files = Get-Childitem -Path $Path *.bicep -File
        if ($files) {
            foreach ($file in $files) {
                if ($file.Name -notin $ExcludeFile) {
                    $ARMTemplate = ParseBicep -Path $file.FullName
                    if ($AsString.IsPresent) {
                        Write-Output $ARMTemplate
                    }
                    else {        
                        if($PSBoundParameters.ContainsKey('OutputDirectory')) {
                            $OutputFilePath = Join-Path -Path $OutputDirectory -ChildPath ('{0}.json' -f $file.BaseName)
                        }
                        else {
                            $OutputFilePath = $file.FullName -replace '\.bicep','.json'
                        }
                        $null = Out-File -Path $OutputFilePath -InputObject $ARMTemplate -Encoding utf8
                        if ($GenerateParameterFile.IsPresent) {
                            GenerateParameterFile -Content $ARMTemplate
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

