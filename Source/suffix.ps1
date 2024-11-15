$BicepTypesPath = Join-Path -Path $PSScriptRoot -ChildPath 'Assets/BicepTypes.json'
$script:TokenSplat = @{}
Write-Verbose "Preloading Bicep types from: '$BicepTypesPath'"
$null = GetBicepTypes -Path "$BicepTypesPath"
if (-not $Script:ModuleVersionChecked) {
    TestModuleVersion
}