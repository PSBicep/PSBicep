function Find-BicepModule {
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { Test-Path $_ })]
        [string]$Path,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Registry,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [switch]$Cache

    )

    process {        
        # Find modules used in local bicep file
        if ($Path) {
            $BicepFile = Get-Childitem -Path $Path -File
        
            try {
                $validBicep = Test-BicepFile -Path $BicepFile.FullName -IgnoreDiagnosticOutput -AcceptDiagnosticLevel Warning
                if (-not ($validBicep)) {
                    throw "The provided bicep is not valid. Make sure that your bicep file builds successfully before publishing."
                }
                else {
                    Write-Verbose "[$($BicepFile.Name)] is valid"
                    Find-BicepModule -Path $Path
                    Write-Verbose -Message "Finding modules used in [$($BicepFile.Name)]"
                }
            }
            catch {
                Throw $_  
            }
        }
        
        # Find modules in ACR
        if ($Registry) {
            try {
                Find-BicepModule -Registry $Registry
                Write-Verbose -Message "Finding all modules stored in: [$Registry]"
            }
            catch {
                Throw $_
            }
        }

        # Find modules in the local cache
        if ($Cache) {
            # Find module
            try {
                Find-BicepModule -Cache
                Write-Verbose -Message "Finding modules in the local module cache"
            }
            catch {
                
            }
        }
    }
}