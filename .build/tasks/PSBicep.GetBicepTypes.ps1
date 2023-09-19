task getBicepTypes {
    $ModuleVersion = Split-ModuleVersion -ModuleVersion (Get-BuiltModuleVersion -OutputDirectory 'output' -ModuleName 'Bicep' -VersionedOutputDirectory)
    $ModuleOutputAssetFolderPath = "output/Bicep/$($ModuleVersion.Version)/Assets"
    $AssetsFolderPath = 'Source/Assets'

    # Download Bicep types
    $BicepTypesFull = Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/Azure/bicep-types-az/main/generated/index.json'
    if ($BicepTypesFull.psobject.Properties.name -notcontains 'Resources') {
        Throw "Bicep types not found."
    }

    # Filter out the resources
    $BicepTypesFiltered = ConvertTo-Json -InputObject $BicepTypesFull.Resources.psobject.Properties.name -Compress

    foreach($FolderPath in $ModuleOutputAssetFolderPath, $AssetsFolderPath) {
        Write-Verbose "Path: $FolderPath" -Verbose
        if(-not (Test-Path -Path $FolderPath)) {
            New-Item -Path $FolderPath -ItemType Directory
        }
        $BicepTypesPath = Join-Path -Path $FolderPath -ChildPath 'BicepTypes.json'
        Out-File -FilePath $BicepTypesPath -InputObject $BicepTypesFiltered
    }
}