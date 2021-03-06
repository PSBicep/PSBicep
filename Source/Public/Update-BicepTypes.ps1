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
        $BicepTypes = Invoke-WebRequest -Uri $BicepTypesUrl -Verbose:$false
    }
    catch {
        Throw "Unable to get new Bicep types from GitHub. $_"
    }

    Write-Verbose "Validating result"

    if ([string]::IsNullOrWhiteSpace($BicepTypes.Content)) {
        Throw "Unable to update Bicep types. Fetched page does not have any content."
    }

    Write-Verbose "Saving to disk"
    
    try {
        Out-File -FilePath $BicepTypesPath -InputObject $BicepTypes.Content -WhatIf:$WhatIfPreference
    }
    catch {
        Throw "Failed to save new Bicep types. $_"
    }

    if (-not $WhatIfPreference) {
        Write-Host "Updated Bicep types with index file generated $($BicepTypes.Headers.Date)"
    }

    # To avoid having to re-import the module, update the module variable
    $null = GetBicepTypes -Path $BicepTypesPath
}