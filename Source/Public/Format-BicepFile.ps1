function Format-BicepFile {
    [CmdletBinding(DefaultParameterSetName = 'Default', SupportsShouldProcess)]
    param (
        [Parameter(ParameterSetName = 'Default', Position = 1)]
        [Parameter(ParameterSetName = 'AsString', Position = 1)]
        [Parameter(ParameterSetName = 'OutputDirectory', Position = 1)]
        [Parameter(ParameterSetName = 'OutputPath', Position = 1)]
        [string]$Path = $pwd.path,

        [Parameter(ParameterSetName = 'OutputDirectory', Position = 2)]
        [ValidateNotNullOrEmpty()]
        [string]$OutputDirectory,

        [Parameter(ParameterSetName = 'OutputPath', Position = 2)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript(
            {
                (Split-Path -Path $_ -Leaf) -match '\.bicep$'
            }
            , ErrorMessage = 'OutputPath needs to be a .bicep-file, e.g. "C:\Output\template.bicep"')]
        [string]$OutputPath,

        [Parameter(ParameterSetName = 'Default', Position = 3)]
        [Parameter(ParameterSetName = 'AsString', Position = 3)]
        [Parameter(ParameterSetName = 'OutputDirectory', Position = 3)]
        [Parameter(ParameterSetName = 'OutputPath', Position = 3)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Auto','LF','CRLF')]
        [string]$NewlineOption = 'Auto',

        [Parameter(ParameterSetName = 'Default', Position = 4)]
        [Parameter(ParameterSetName = 'AsString', Position = 4)]
        [Parameter(ParameterSetName = 'OutputDirectory', Position = 4)]
        [Parameter(ParameterSetName = 'OutputPath', Position = 4)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Space','Tab')]
        [string]$IndentKindOption = 'Space',

        [Parameter(ParameterSetName = 'Default', Position = 5)]
        [Parameter(ParameterSetName = 'AsString', Position = 5)]
        [Parameter(ParameterSetName = 'OutputDirectory', Position = 5)]
        [Parameter(ParameterSetName = 'OutputPath', Position = 5)]
        [ValidateNotNullOrEmpty()]
        [int]$IndentSize = 2,

        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'AsString')]
        [Parameter(ParameterSetName = 'OutputDirectory')]
        [Parameter(ParameterSetName = 'OutputPath')]
        [switch]$InsertFinalNewline,

        [Parameter(ParameterSetName = 'AsString')]
        [switch]$AsString
    )

    begin {
        if ($PSBoundParameters.ContainsKey('OutputDirectory') -and (-not (Test-Path $OutputDirectory))) {
            $null = New-Item $OutputDirectory -Force -ItemType Directory -WhatIf:$WhatIfPreference
        }
        if ($PSBoundParameters.ContainsKey('OutputPath') -and (-not (Test-Path $OutputPath)) -and -not [string]::IsNullOrEmpty((Split-Path -Path $OutputPath))) {
            $null = New-Item (Split-Path -Path $OutputPath) -Force -ItemType Directory -WhatIf:$WhatIfPreference
        }
        if ($PSBoundParameters.ContainsKey('OutputPath') -and ((Split-Path -Path $Path -Leaf) -notmatch '\.bicep$')) { 
            Write-Error 'If -Path and -OutputPath parameters are used, only one .bicep file can be used as input to -Path. E.g. -Path "C:\Output\template.bicep" -OutputPath "C:\Output\formatted.bicep".'
            Break
        }
        if ($VerbosePreference -eq [System.Management.Automation.ActionPreference]::Continue) {
            $FullVersion = Get-BicepVersion -Verbose:$false
            Write-Verbose -Message "Using Bicep version: $FullVersion"
        }
    }

    process {
        $files = Get-ChildItem -Path $Path *.bicep -File
        if ($files) {
            foreach ($file in $files) {
                if ($VerbosePreference -eq [System.Management.Automation.ActionPreference]::Continue) {
                    $bicepConfig = Get-BicepConfig -Path $file
                    Write-Verbose -Message "Using Bicep configuration: $($bicepConfig.Path)"
                }

                # Set up splatting with common parameters for Bicep
                $Params = @{
                    'NewlineOption' = $NewlineOption
                    'IndentKindOption' = $IndentKindOption
                    'IndentSize' = $IndentSize
                    'InsertFinalNewline' = $InsertFinalNewline.IsPresent
                    'Content' = Get-Content -Path $file -Raw
                }
                $FormattedBicep = Format-Bicep @Params

                if (-not [string]::IsNullOrWhiteSpace($FormattedBicep)) {
                    if ($AsString.IsPresent) {
                        Write-Output $FormattedBicep
                    }
                    else {
                        if ($PSBoundParameters.ContainsKey('OutputPath')) {
                            $OutputFilePath = $OutputPath
                        }
                        elseif ($PSBoundParameters.ContainsKey('OutputDirectory')) {
                            $OutputFilePath = Join-Path -Path $OutputDirectory -ChildPath ('{0}.bicep' -f $file.BaseName)
                        }
                        else {
                            $OutputFilePath = $file.FullName
                        }
                        $null = Out-File -Path $OutputFilePath -InputObject $FormattedBicep -Encoding utf8 -WhatIf:$WhatIfPreference
                    }
                }
            }
        }
        else {
            Write-Host "No bicep files located in path $Path"
        }
    }
}