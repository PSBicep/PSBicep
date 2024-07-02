task GenerateTestCases {
    $ModuleVersion = Split-ModuleVersion -ModuleVersion (Get-BuiltModuleVersion -OutputDirectory 'output' -ModuleName 'BicepNet.PS' -VersionedOutputDirectory)
    $ModuleOutputPath = "output/BicepNet.PS/$($ModuleVersion.Version)/BicepNet.PS"
    Import-Module (Convert-Path $ModuleOutputPath)
    $ModuleCommands = Get-Command -Module 'BicepNet.PS'
    $CommandList = foreach ($Command in $ModuleCommands) {
        [PSCustomObject]@{
            CommandName = $Command.Name
            Parameters = $Command.parameters.Keys | ForEach-Object {
                [PSCustomObject]@{
                    ParameterName = $_
                    ParameterType = $Command.parameters[$_].ParameterType.FullName
                }
            }
        }
    }
    $CommandList | ConvertTo-Json -Depth 3 | Out-File 'BicepNet.PS/tests/BicepNet.PS.ParameterTests.json'
}
