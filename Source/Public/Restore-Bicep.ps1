function Restore-Bicep {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]$Path         
    )

    begin {   
        
    }

    process {
        $BicepToken = @{}
        $BicepFile = Get-Childitem -Path $Path -File
        $Config = Get-BicepConfig -Path $BicepFile
        try {
            AssertAzureConnection -TokenSplat $script:TokenSplat -BicepConfig $Config -ErrorAction 'Stop'
            $BicepToken['Token'] = $script:Token.Token
        } catch {
            # We don't care about errors here, let bicep throw if authentication is needed
        }
        
        if ($VerbosePreference -eq [System.Management.Automation.ActionPreference]::Continue) {
            
            Write-Verbose -Message "Using Bicep configuration: $($bicepConfig.Path)"
        }

        # Restore modules
        try {
            Restore-BicepFile -Path $BicepFile.FullName @BicepToken -ErrorAction Stop
            Write-Verbose -Message "Successfully restored all modules"
        }
        catch {
            Throw $_
        }
    }
}