function Update-BicepTypes {
    $ModulePath = (Get-Module -ListAvailable Bicep).Path
    $ModuleFolder = Split-Path -Path $ModulePath
           
    $BicepTypesPath = Join-Path -Path $ModuleFolder -ChildPath 'Assets\BicepTypes.json'
    try {
        $BicepTypes=Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Azure/bicep-types-az/main/generated/index.json' 
        Out-File -FilePath $BicepTypesPath -InputObject $BicepTypes.Content
        Write-Host "Updated Bicep types data with index file generated $($BicepTypes.Headers.Date)"
    }
    catch {
        Throw "Unable to update Bicep types information"           
    }    
}