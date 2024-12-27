$script:BicepTypesPath = Join-Path -Path $PSScriptRoot -ChildPath 'Assets/BicepTypes.json'
$script:ModuleManifestPath = Join-Path -Path $PSScriptRoot -ChildPath 'Bicep.psd1'
$script:TokenSplat = @{}
Write-Verbose "Preloading Bicep types from: '$BicepTypesPath'"
$null = GetBicepTypes -Path "$BicepTypesPath"
TestModuleVersion