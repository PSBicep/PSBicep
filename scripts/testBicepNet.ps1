param(
    $BicepNetPath = '../BicepNet/output/BicepNet.PS'
)

if(-not (Test-Path -Path $BicepNetPath)) {
    throw "BicepNetPath '$BicepNetPath' does not exist."
}

$ModuleVersion = Split-ModuleVersion -ModuleVersion (Get-BuiltModuleVersion -OutputDirectory 'output' -ModuleName 'Bicep' -VersionedOutputDirectory)
$ModuleOutputPath = "output/Bicep/$($ModuleVersion.Version)"

$RequiredBicepNetModuleVersion = Get-Metadata -Path "$BicepNetPath/*/BicepNet.PS.psd1" -PropertyName 'ModuleVersion' -ErrorAction 'Stop'
Copy-Item -Path "$BicepNetPath/$RequiredBicepNetModuleVersion" -Destination "$ModuleOutputPath/BicepNet.PS/" -Force -Recurse -ErrorAction 'Stop'
Update-Metadata -Path "$ModuleOutputPath/Bicep.psd1" -PropertyName 'NestedModules' -Value @("./BicepNet.PS/$RequiredBicepNetModuleVersion/BicepNet.PS.psd1") -ErrorAction 'Stop'

./build.ps1 -Tasks Set_PSModulePath, Pester_Tests_Stop_On_Fail