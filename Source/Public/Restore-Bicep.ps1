function Restore-Bicep {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]$Path         
    )

    # Check if a newer version of the module is published
    if (-not $Script:ModuleVersionChecked) {
        TestModuleVersion
    }

    # Verbose output Bicep Version used
    $FullVersion = Get-BicepNetVersion -Verbose:$false
    Write-Verbose -Message "Using Bicep version: $FullVersion"
  
    # Restore modules
    try {
        Restore-BicepNetFile -Path $Path -ErrorAction Stop
        Write-Verbose -Message "Successfully restored all modules"
    }
    catch {
        Throw $_
    }

}