task copyBicepNetPSToOutput {
    $RequiredBicepNetModuleVersion = Get-Metadata -Path 'RequiredModules.psd1' -PropertyName 'BicepNet.PS' -ErrorAction 'Stop'
    $ModuleVersion = Split-ModuleVersion -ModuleVersion (Get-BuiltModuleVersion -OutputDirectory 'output' -ModuleName 'Bicep' -VersionedOutputDirectory)
    $ModuleOutputPath = "output/Bicep/$($ModuleVersion.Version)"
    $null = New-Item -Path "$ModuleOutputPath/BicepNet.PS" -ItemType 'Directory' -Force -ErrorAction 'Stop'
    Copy-Item -Path "output/RequiredModules/BicepNet.PS/$RequiredBicepNetModuleVersion" -Destination "$ModuleOutputPath/BicepNet.PS/" -Force -Recurse -ErrorAction 'Stop'
    Update-Metadata -Path "$ModuleOutputPath/Bicep.psd1" -PropertyName 'NestedModules' -Value @("./BicepNet.PS/$RequiredBicepNetModuleVersion/BicepNet.PS.psd1") -ErrorAction 'Stop'
}

task copyBicepNetPSToSource {
    $RequiredBicepNetModuleVersion = Get-Metadata -Path 'RequiredModules.psd1' -PropertyName 'BicepNet.PS' -ErrorAction 'Stop'
    $ModuleSourcePath = "Source/"
    $null = New-Item -Path "$ModuleSourcePath/BicepNet.PS" -ItemType 'Directory' -Force -ErrorAction 'Stop'
    Copy-Item -Path "output/RequiredModules/BicepNet.PS/$RequiredBicepNetModuleVersion" -Destination "$ModuleSourcePath/BicepNet.PS/" -Force -Recurse -ErrorAction 'Stop'
    Update-Metadata -Path "$ModuleSourcePath/Bicep.psd1" -PropertyName 'NestedModules' -Value @("./BicepNet.PS/$RequiredBicepNetModuleVersion/BicepNet.PS.psd1") -ErrorAction 'Stop'
}