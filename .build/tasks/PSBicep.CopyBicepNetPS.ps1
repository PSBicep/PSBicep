task copyBicepNetPS {
    $RequiredBicepNetModuleVersion = Get-Metadata -Path 'RequiredModules.psd1' -PropertyName 'BicepNet.PS' -ErrorAction 'Stop'
    $ModuleVersion = Get-BuiltModuleVersion -OutputDirectory 'output' -ModuleName 'Bicep' -VersionedOutputDirectory
    $ModuleOutputPath = "output/Bicep/$ModuleVersion"
    $null = New-Item -Path "$ModuleOutputPath/BicepNet.PS" -ItemType 'Directory' -Force -ErrorAction 'Stop'
    Copy-Item -Path "output/RequiredModules/BicepNet.PS/$RequiredBicepNetModuleVersion" -Destination "$ModuleOutputPath/BicepNet.PS/" -Force -Recurse -ErrorAction 'Stop'
    Update-Metadata -Path 'output/Bicep/*/Bicep.psd1' -PropertyName 'NestedModules' -Value @("./BicepNet.PS/$RequiredBicepNetModuleVersion/BicepNet.PS.psd1") -ErrorAction 'Stop'
}