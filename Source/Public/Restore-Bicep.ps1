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
        $FullVersion = Get-BicepVersion -Verbose:$false
        Write-Verbose -Message "Using Bicep version: $FullVersion"
    }

    process {
        $BicepFile = Get-Childitem -Path $Path -File

        if ($VerbosePreference -eq [System.Management.Automation.ActionPreference]::Continue) {
            $bicepConfig= Get-BicepConfig -Path $BicepFile
            Write-Verbose -Message "Using Bicep configuration: $($bicepConfig.Path)"
        }

        # Restore modules
        try {
            Restore-BicepFile -Path $BicepFile.FullName -ErrorAction Stop
            Write-Verbose -Message "Successfully restored all modules"
        }
        catch {
            Throw $_
        }
    }
}