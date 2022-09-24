function Get-BicepConfig {
    [CmdletBinding(DefaultParameterSetName='Default')]
    param (
        [Parameter(ParameterSetName='PathOnly', Mandatory)]
        [Parameter(ParameterSetName='PathLocal', Mandatory)]
        [Parameter(ParameterSetName='PathMerged', Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { Test-Path $_ } , ErrorMessage = "File not found")]
        [string]$Path,

        [Parameter(ParameterSetName='PathLocal', Mandatory)]
        [Switch]$Local,

        [Parameter(ParameterSetName='PathMerged', Mandatory)]
        [Switch]$Merged,

        [Parameter(ParameterSetName='Default')]
        [Switch]$Default
    )
    begin {
        # Check if a newer version of the module is published
        if (-not $Script:ModuleVersionChecked) {
            TestModuleVersion
        }
    }

    process {
        if ($Path) {
            $BicepFile = Resolve-Path -Path $Path
        }
        $Params = @{
            Scope = 'Merged'
        }
        switch -Wildcard ($PSCmdlet.ParameterSetName) {
            'PathLocal' {
                $Params['Scope'] = 'Local'
            }
            'Path*' {
                $Params['Path'] = $BicepFile
            }
            'Default' {
                $Params['Scope'] = 'Default'
            }
        }
        try {
            Get-BicepNetConfig @Params -ErrorAction 'Stop'
        }
        catch [System.ArgumentException] {
            # Failed to locate a bicepconfig, get the default config instead.
            Get-BicepNetConfig -Scope 'Default' -ErrorAction 'Stop'
        }
    }
}