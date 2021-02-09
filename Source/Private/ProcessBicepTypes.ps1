function ProcessBicepTypes {
    param (
        [string]$Name
    )
    
    $types = Get-Content -Path .\tmp\index.json | ConvertFrom-Json -AsHashtable
    $types = $types.Types
    $allResourceProviders = [System.Collections.ArrayList]::new()
    foreach ($type in $types.Keys) {        
    
        $ResourceProviders = [PSCustomObject]@{
            ResoruceProvider = ($type -split "/")[0]
        }
        $null = $allResourceProviders.Add($ResourceProviders)
    }
   
    $null = $allResourceProviders = $allResourceProviders | Group-Object ResoruceProvider
    
    if ([string]::IsNullOrEmpty($Name)) {
        $allResourceProviders.Name
    }
    else {
        $allResourceProviders.Name.where({$_ -like "$Name*"})
    }
}