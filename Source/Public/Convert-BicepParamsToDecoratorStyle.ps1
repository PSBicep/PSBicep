function Convert-BicepParamsToDecoratorStyle {
    [CmdletBinding()]
    param(
        [string]$Path,
        [switch]$ToClipboard
    )

    Write-Error "The Convert-BicepParamsToDecoratorStyle has been decommissioned starting version 1.5.0 of the module."  
    Write-Error "Parameter modifiers are no longer supported in Bicep v0.4 which is used by this version of the module."
    Write-Error "To be able to convert parameters to decorator style use version 1.4.7 of the Bicep module which is using Bicep v0.3.539 assemblies."
}