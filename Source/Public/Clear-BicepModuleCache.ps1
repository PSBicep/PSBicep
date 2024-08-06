function Clear-BicepModuleCache {
    [CmdletBinding(DefaultParameterSetName = 'Oci')]
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
        [string]$Version,

        [Parameter(ParameterSetName = 'All', Position = 1)]
        [switch]$All
     
    )
    process {
        
        if ($Oci -or $All) {            
            $OciPath = Get-BicepCachePath -Oci 
            $RepositoryPath = $Repository -replace '\\', '$'

            if (($Registry) -and ($Repository) -and ($Version)) {
                Remove-Item -Recurse -Path "$OciPath/$Registry/$RepositoryPath/$Version`$" -Force
                Write-Verbose "Cleared version [$Version] of [$Repository] in [$Registry] from local module cache"
            }
            elseif (($Registry) -and ($Repository)) {
                Remove-Item -Recurse -Path "$OciPath/$Registry/$RepositoryPath" -Force
                Write-Verbose "Cleared [$Repository] in [$Registry] from local module cache"
            }
            elseif ($Registry) {
                Remove-Item -Recurse -Path "$OciPath/$Registry" -Force
                Write-Verbose "Cleared [$Registry] from local module cache" 
            }
            else {
                if (Test-Path -Path $OciPath) {
                    Remove-Item -Recurse -Path $OciPath -Force
                    Write-Verbose "Cleared Oci local module cache" 
                }
                else {
                    Write-Verbose "No Oci local module cache found" 
                }
            }            
        }
        
        if ($TemplateSpecs -or $All) {            
            $TSPath = Get-BicepCachePath -TemplateSpecs

            if (($SubscriptionId) -and ($ResourceGroup) -and ($Spec) -and ($Version)) {
                Remove-Item -Recurse -Path "$TSPath/$SubscriptionId/$ResourceGroup/$Spec/$Version" -Force
                Write-Verbose "Cleared version [$Version] of [$Spec] in [$ResourceGroup] in [$SubscriptionId] from local module cache"
            }
            elseif (($SubscriptionId) -and ($ResourceGroup) -and ($Spec)) {
                Remove-Item -Recurse -Path "$TSPath/$SubscriptionId/$ResourceGroup/$Spec" -Force
                Write-Verbose "Cleared [$Spec] in [$ResourceGroup] in [$SubscriptionId] from local module cache"
            }
            elseif (($SubscriptionId) -and ($ResourceGroup)) {
                Remove-Item -Recurse -Path "$TSPath/$SubscriptionId/$ResourceGroup" -Force
                Write-Verbose "Cleared [$ResourceGroup] in [$SubscriptionId] from local module cache"
            }
            elseif ($SubscriptionId) {
                Remove-Item -Recurse -Path "$TSPath/$SubscriptionId" -Force
                Write-Verbose "Cleared [$SubscriptionId] from local module cache" 
            }
            else {
                if (Test-Path -Path $TSPath) {
                    Remove-Item -Recurse -Path $TSPath -Force
                    Write-Verbose "Cleared Template Spec local module cache" 
                }
                else {
                    Write-Verbose "No Template Spec local module cache found" 
                }
            }            
        }            
    }
}