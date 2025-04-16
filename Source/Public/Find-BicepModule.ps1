function Find-BicepModule {
    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName = 'Path', Mandatory = $true, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { Test-Path $_ })]
        [string]$Path,

        [Parameter(ParameterSetName = 'Registry', Mandatory = $true, Position = 1)]
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Registry,

        [Parameter(ParameterSetName = 'Registry', Mandatory = $false, Position = 2)]
        [string]$ConfigurationPath,

        [Parameter(ParameterSetName = 'Cache', Mandatory = $true, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [switch]$Cache

    )

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'Path' {
                $BicepFile = Get-Childitem -Path $Path -File

                $validBicep = Test-BicepFile -Path $BicepFile.FullName -IgnoreDiagnosticOutput -AcceptDiagnosticLevel Warning
                if (-not ($validBicep)) {
                    throw "The provided bicep is not valid. Make sure that your bicep file builds successfully before publishing."
                }

                Write-Verbose "[$($BicepFile.Name)] is valid"
                Write-Verbose -Message "Finding modules used in [$($BicepFile.Name)]"
                Find-BicepModule -Path $Path -ErrorAction 'Stop'
              
            }
            'Registry' {
                Write-Verbose -Message "Finding all modules stored in: [$Registry]"
                Find-BicepModule -Registry $Registry -ErrorAction 'Stop'

            }
            'Cache' {
                Write-Verbose -Message "Finding modules in the local module cache"
                Find-BicepModule -Cache -ErrorAction 'Stop'
            }
        }
    }
}