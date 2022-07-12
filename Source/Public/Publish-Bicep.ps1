function Publish-Bicep {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({Test-Path $_})]
        [string]$Path,

        [Parameter(Mandatory, Position = 2)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^(?<Prefix>[bBrR]{2})(?<ACROrAlias>(:[\w\-_]+\.azurecr.io|\/[\w\-\._]+:))(?<path>[\w\/\-\._]+)(?<tag>:[\w\/\-\._]+)$', ErrorMessage = 'Target does not match pattern for registry. Specify a path to a registry using "br:", or "br/" if using an alias.')]
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

        if ($VerbosePreference -eq [System.Management.Automation.ActionPreference]::Continue) {
            $bicepConfig= Get-BicepConfig -Path $BicepFile
            Write-Verbose -Message "Using bicepconfig.json: $($bicepConfig.Path)"
        }

        # Publish module
        try {
            Publish-BicepNetFile -Path $BicepFile.FullName -Target $Target -ErrorAction Stop
            Write-Verbose -Message "[$($BicepFile.Name)] published to: [$Target]"
        }
        catch {
            Throw $_
        }
    }
}