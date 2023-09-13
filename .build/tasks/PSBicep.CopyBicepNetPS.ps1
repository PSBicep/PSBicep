task copyBicepNetPS {
    $RequiredBicepNetModuleVersion = Get-Metadata -Path 'RequiredModules.psd1' -PropertyName 'BicepNet.PS' -ErrorAction 'Stop'
    $ModuleVersion = Get-BuiltModuleVersion -OutputDirectory 'output' -ModuleName 'Bicep' -VersionedOutputDirectory
    $ModuleOutputPath = "output/Bicep/$ModuleVersion"
    $ModuleSourcePath = "Source/"
    foreach($Path in $ModuleOutputPath, $ModuleSourcePath) {
        $null = New-Item -Path "$Path/BicepNet.PS" -ItemType 'Directory' -Force -ErrorAction 'Stop'
        Copy-Item -Path "output/RequiredModules/BicepNet.PS/$RequiredBicepNetModuleVersion" -Destination "$Path/BicepNet.PS/" -Force -Recurse -ErrorAction 'Stop'
        Update-Metadata -Path "$Path/Bicep.psd1" -PropertyName 'NestedModules' -Value @("./BicepNet.PS/$RequiredBicepNetModuleVersion/BicepNet.PS.psd1") -ErrorAction 'Stop'
    }
}