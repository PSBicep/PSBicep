function Restore-Bicep {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]$Path         
    )

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