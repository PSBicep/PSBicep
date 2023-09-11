task getBicepTypes {
    $AssetsFolderPath = 'Source/Assets'
    if(-not (Test-Path -Path $AssetsFolderPath)) {
        $null = New-Item -Path $AssetsFolderPath -ItemType Directory
    }

    # Download Bicep types
    $BicepTypesFull = Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/Azure/bicep-types-az/main/generated/index.json'
    if ($BicepTypesFull.psobject.Properties.name -notcontains 'Resources') {
        Throw "Bicep types not found."
    }

    # Filter out the resources and save to disk
    $BicepTypesFiltered = ConvertTo-Json -InputObject $BicepTypesFull.Resources.psobject.Properties.name -Compress
    $BicepTypesPath = Join-Path -Path $AssetsFolderPath -ChildPath 'BicepTypes.json'
    Out-File -FilePath $BicepTypesPath -InputObject $BicepTypesFiltered
}