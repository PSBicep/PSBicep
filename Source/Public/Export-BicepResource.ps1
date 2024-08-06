function Export-BicepResource {
    [CmdletBinding(DefaultParameterSetName = 'Path')]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'Path')]
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'AsString')]
        [string[]]$ResourceId,

        [Parameter(ParameterSetName = 'AsString')]
        [Parameter(ParameterSetName = 'Path')]
        [switch]$IncludeTargetScope,

        [Parameter(Mandatory, ParameterSetName = 'AsString')]
        [switch]$AsString,

        [Parameter(Mandatory, ParameterSetName = 'Path')]
        [ValidateNotNullOrEmpty()]
        [ValidateScript(
            {
                (Split-path -path $_ -leaf) -match "\.bicep$"
            }
            , ErrorMessage = 'Path needs to be a .bicep-file, e.g. "C:\Output\resource.bicep"')]
        [string]$Path
    )

    begin {
        # Create the directory if it does not exist
        if ($PSBoundParameters.ContainsKey('Path') -and (-not (Test-Path $Path))) {
            $null = New-Item (Split-Path -Path $Path) -Force -ItemType Directory -WhatIf:$WhatIfPreference
        }
    }

    process {
        $Params = @{
            ResourceId = $ResourceId
            IncludeTargetScope = $IncludeTargetScope.IsPresent
        }
        switch ($PSCmdlet.ParameterSetName) {
            'AsString' { (Export-BicepResource @Params).Values }
            'Path' {
                $Dict = Export-BicepResource @Params
                Out-File -InputObject $Dict.Values -FilePath $Path -Encoding utf8 -Force
            }
        }
    }
}