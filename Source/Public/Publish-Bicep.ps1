function Publish-Bicep {
    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName = 'Default', Mandatory, Position = 1)]
        [Parameter(ParameterSetName = 'Registry', Position = 1)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { Test-Path $_ })]
        [string]$Path,

        [Parameter(ParameterSetName = 'Default', Position = 2)]
        [ValidateNotNullOrEmpty()]
        [string]$Target,
        
        [Parameter(ParameterSetName = 'Registry', Mandatory, Position = 2)]
        [ValidateNotNullOrEmpty()]
        [string]$Registry,

        [Parameter(ParameterSetName = 'Registry', Mandatory, Position = 3)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { $_ -notlike '/*' },
        ErrorMessage = "Repository must be defined without a leading /")] 
        [string]$Repository,

        [Parameter(ParameterSetName = 'Registry', Mandatory, Position = 4)]
        [ValidateNotNullOrEmpty()]
        [string]$Tag
        
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

        # Set target for publish
        if (-not $Target) {
            if ($Registry -like '*azurecr.io*') {
                $publishTarget = "br:{0}/{1}:{2}" -f $Registry, $Repository, $Tag
            }
            else {
                $publishTarget = "br/{0}:{1}:{2}" -f $Registry, $Repository, $Tag
            }
        }
        else {
            $publishTarget = $Target
        }
        
        # Publish module
        try {
            Publish-BicepNetFile -Path $BicepFile.FullName -Target $publishTarget -ErrorAction Stop
            Write-Verbose -Message "[$($BicepFile.Name)] published to: [$publishTarget]"
        }
        catch {
            Throw $_
        }
    }
}