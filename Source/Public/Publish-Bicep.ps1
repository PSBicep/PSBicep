function Publish-Bicep {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter(Mandatory, Position = 2)]
        [ValidateNotNullOrEmpty()]
        [string]$Target          
    )
    begin {
        # Check if a newer version of the module is published
        if (-not $Script:ModuleVersionChecked) {
            TestModuleVersion
        }       
    }

    process {
        $BicepFile = Get-Childitem -Path $Path -File
        $LoginServer = (($target -split ":")[1] -split "/")[0]
    
        try {
            $validBicep = Test-BicepFile -Path $BicepFile.FullName -IgnoreDiagnosticOutput -AcceptDiagnosticLevel Warning
            if (-not ($validBicep)) {
                throw "The provided bicep is not valid. Make sure that your bicep file builds successfully before publishing."
            }
            else {
                Write-Verbose "[$($BicepFile.Name)] is valid"
            }
        }
        catch {
            Throw $_  
        }

        # Publish module
        try {
            Publish-BicepNetFile -Path $BicepFile.FullName -Target $Target -ErrorAction Stop
            Write-Verbose -Message "Successfully authenticated to $LoginServer"
            Write-Verbose -Message "[$($BicepFile.Name)] published to: [$Target]"
        }
        catch {
            Throw $_
        }
    }
}