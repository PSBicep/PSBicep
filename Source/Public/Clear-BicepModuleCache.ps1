function Clear-BicepModuleCache {
    [CmdletBinding()]
    param (
        
        [Parameter(ParameterSetName = 'Oci', Position = 1)]
        [switch]$Oci,

        [Parameter(ParameterSetName = 'Oci', Position = 2)]
        [ValidateNotNullOrEmpty()]
        [string]$Registry,

        [Parameter(ParameterSetName = 'Oci', Position = 3)]
        [ValidateNotNullOrEmpty()]
        [string]$Repository,

        [Parameter(ParameterSetName = 'TemplateSpecs', Position = 1)]
        [switch]$TemplateSpecs,

        [Parameter(ParameterSetName = 'TemplateSpecs', Position = 2)]
        [ValidateNotNullOrEmpty()]
        [string]$SubscriptionId,

        [Parameter(ParameterSetName = 'TemplateSpecs', Position = 3)]
        [ValidateNotNullOrEmpty()]
        [string]$ResourceGroup,

        [Parameter(ParameterSetName = 'TemplateSpecs', Position = 4)]
        [ValidateNotNullOrEmpty()]
        [string]$Spec,

        [Parameter(ParameterSetName = 'Oci', Position = 4)]
        [Parameter(ParameterSetName = 'TemplateSpecs', Position = 5)]
        [ValidateNotNullOrEmpty()]
        [string]$Version
     
    )
    begin {
        # Check if a newer version of the module is published
        if (-not $Script:ModuleVersionChecked) {
            TestModuleVersion
        }       
    }

    process {
        
        if ($Oci) {            
            $OciPath = Get-BicepNetCachePath -Oci 
            $RepositoryPath = $Repository -replace '\\', '$'

            if (($Registry) -and ($Repository) -and ($Version)) {
                Remove-Item -Recurse -Path "$OciPath/$Registry/$RepositoryPath/$Version$"
                Write-Verbose "Cleared version [$Version] of [$Repository] in [$Registry] from local module cache"
            }
            elseif (($Registry) -and ($Repository)) {
                Remove-Item -Recurse -Path "$OciPath/$Registry/$RepositoryPath"
                Write-Verbose "Cleared [$Repository] in [$Registry] from local module cache"
            }
            elseif ($Registry) {
                Remove-Item -Recurse -Path "$OciPath/$Registry"
                Write-Verbose "Cleared [$Registry] from local module cache" 
            }
            else {
                if (Test-Path -Path $OciPath) {
                    Remove-Item -Recurse -Path $OciPath
                    Write-Verbose "Cleared Oci local module cache" 
                }
                else {
                    Write-Verbose "No Oci local module cache found" 
                }
            }            
        }
        
        if ($TemplateSpecs) {            
            $TSPath = Get-BicepNetCachePath -TemplateSpecs

            if (($SubscriptionId) -and ($ResourceGroup) -and ($Spec) -and ($Version)) {
                Remove-Item -Recurse -Path "$TSPath/$SubscriptionId/$ResourceGroup/$Spec/$Version"
                Write-Verbose "Cleared version [$Version] of [$Spec] in [$ResourceGroup] in [$SubscriptionId] from local module cache"
            }
            elseif (($SubscriptionId) -and ($ResourceGroup) -and ($Spec)) {
                Remove-Item -Recurse -Path "$TSPath/$SubscriptionId/$ResourceGroup/$Spec"
                Write-Verbose "Cleared [$Spec] in [$ResourceGroup] in [$SubscriptionId] from local module cache"
            }
            elseif (($SubscriptionId) -and ($ResourceGroup)) {
                Remove-Item -Recurse -Path "$TSPath/$SubscriptionId/$ResourceGroup"
                Write-Verbose "Cleared [$ResourceGroup] in [$SubscriptionId] from local module cache"
            }
            elseif ($SubscriptionId) {
                Remove-Item -Recurse -Path "$TSPath/$SubscriptionId"
                Write-Verbose "Cleared [$SubscriptionId] from local module cache" 
            }
            else {
                if (Test-Path -Path $TSPath) {
                    Remove-Item -Recurse -Path $TSPath
                    Write-Verbose "Cleared Template Spec local module cache" 
                }
                else {
                    Write-Verbose "No Template Spec local module cache found" 
                }
            }            
        }
    }
}