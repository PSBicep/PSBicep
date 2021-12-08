function Restore-Bicep {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]$Path         
    )

    begin {
        # Check if a newer version of the module is published
        if (-not $Script:ModuleVersionChecked) {
            TestModuleVersion
        }

        # Verbose output Bicep Version used
        $FullVersion = Get-BicepNetVersion -Verbose:$false
        Write-Verbose -Message "Using Bicep version: $FullVersion"
    }

    process {
        $BicepFile = Get-Childitem -Path $Path -File
    
        # Restore modules
        try {
            Restore-BicepNetFile -Path $BicepFile.FullName -ErrorAction Stop
            Write-Verbose -Message "Successfully restored all modules"
        }
        catch {
            Throw $_
        }
    }
}