function Export-BicepChildResource {
    [CmdletBinding(DefaultParameterSetName='OutputPath')]
    param (
        [Parameter(Mandatory, ParameterSetName='AsString', Position = 1)]
        [Parameter(Mandatory, ParameterSetName='OutputPath', Position = 1)]
        [string]$ParentResourceId,

        [Parameter(Mandatory, ParameterSetName='OutputPath', Position = 2)]
        [string]$OutputDirectory,

        [Parameter(Mandatory, ParameterSetName='AsString', Position = 2)]
        [switch]$AsString
    )

    begin {
        if ($PSBoundParameters.ContainsKey('OutputDirectory') -and (-not (Test-Path $OutputDirectory))) {
            $null = New-Item $OutputDirectory -Force -ItemType Directory -WhatIf:$WhatIfPreference
        }
    }

    process {
        $ChildResources = Export-BicepChildResource -ParentResourceId $ParentResourceId
        foreach($key in $ChildResources.Keys) {
            switch ($pscmdlet.ParameterSetName) {
                'OutputPath' { 
                    $Path = Join-Path -Path $OutputDirectory -ChildPath "$key.bicep"
                    Out-File -FilePath $Path -InputObject $ChildResources[$key] -Encoding utf8 -Force
                }
                'AsString' {
                    Write-Output $ChildResources[$key]
                }
            }
        }
    }
}