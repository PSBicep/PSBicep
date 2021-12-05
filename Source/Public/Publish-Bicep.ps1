function Publish-Bicep {
    param (
        [Parameter(Mandatory, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter(Mandatory, Position = 2)]
        [ValidateNotNullOrEmpty()]
        [string]$Target         
    )

    # Check if a newer version of the module is published
    if (-not $Script:ModuleVersionChecked) {
        TestModuleVersion
    }

    # Verbose output Bicep Version used
    $FullVersion = Get-BicepNetVersion -Verbose:$false
    Write-Verbose -Message "Using Bicep version: $FullVersion"

    $BicepFile= Get-Childitem -Path $Path *.bicep -File
    $LoginServer=(($target -split ":")[1] -split "/")[0]
    

    # Publish module
    try {
        Publish-BicepNetFile -Path $Path -Target $Target
        Write-Verbose -Message "Template: [$($BicepFile.Name)] published to: [$Target]"
    }
    catch {
        Throw $_
    }


}