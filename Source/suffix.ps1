$BicepTypesPath = Join-Path -Path $PSScriptRoot -ChildPath 'Assets/BicepTypes.json'
Write-Verbose "Preloading Bicep types from: '$BicepTypesPath'"
$null = GetBicepTypes -Path "$BicepTypesPath"