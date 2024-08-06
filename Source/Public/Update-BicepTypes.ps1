function Update-BicepTypes {
    [CmdletBinding(SupportsShouldProcess)]
    param ()

    $ModulePath = (Get-Module Bicep).Path
    $ModuleFolder = Split-Path -Path $ModulePath

    # Where the file is stored
    $BicepTypesPath = Join-Path -Path $ModuleFolder -ChildPath 'Assets\BicepTypes.json'
    
    # Url to fetch new types from
    $BicepTypesUrl = 'https://raw.githubusercontent.com/Azure/bicep-types-az/main/generated/index.json'
    
    Write-Verbose "Fetching types from GitHub: $BicepTypesUrl"
    
    try {
        $BicepTypes = Invoke-RestMethod -Uri $BicepTypesUrl -Verbose:$false
    }
    catch {
        Throw "Unable to get new Bicep types from GitHub. $_"
    }

    Write-Verbose "Filtering content"
    
    # If the Resources property does not exist we want to throw an error
    if ($BicepTypes.psobject.Properties.name -notcontains 'Resources') {
        Throw "Resources not found in index file."
    }

    try {
        $TypesOnly = ConvertTo-Json -InputObject $BicepTypes.Resources.psobject.Properties.name -Compress
    }
    catch {
        Throw "Unable to filter content. Index file might have changed. $_"
    }

    Write-Verbose "Saving to disk"
    
    try {
        Out-File -FilePath $BicepTypesPath -InputObject $TypesOnly -WhatIf:$WhatIfPreference
    }
    catch {
        Throw "Failed to save new Bicep types. $_"
    }

    if (-not $WhatIfPreference) {
        Write-Host "Updated Bicep types."
    }

    # To avoid having to re-import the module, update the module variable
    $null = GetBicepTypes -Path $BicepTypesPath
}