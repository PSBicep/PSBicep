$BicepTypesPath = Join-Path -Path (Split-Path (Get-Module Bicep).Path) -ChildPath 'Assets/BicepTypes.json'
Write-Verbose "Preloading Bicep types from: '$BicepTypesPath'"
$null = GetBicepTypes -Path "$BicepTypesPath"