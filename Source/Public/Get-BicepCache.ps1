function Get-BicepCache {
    [CmdLetBinding()]
    param(        
        [ValidateSet("br", "ts")]
        [string]$Type
    )
    
    begin {
        if (-not $Script:ModuleVersionChecked) {
            TestModuleVersion
        }
    }

    process {

        # WIP - Manage Template spec cache
        if ($Type -eq 'ts') {
            $templateSpecCache = Get-ChildItem -Path "$env:USERPROFILE/.bicep/ts"
            $templateSpecCache
        }
        
        #WIP - Manage bicep registry cache
        if ($Type -eq 'br') {
            # Get all module registries 
            $privateRegistryCache = Get-ChildItem -Path "$env:USERPROFILE/.bicep/br"
            $registryHash = [ordered]@{}
            # Get all repos per registry
            foreach ($acr in $privateRegistryCache) {
                # Get all cached versions
                $repositories = Get-ChildItem -Path $acr
                foreach ($version in $repositories) {
                    $versions = Get-ChildItem -Path $version

                }
            }           
        }
    }    
}