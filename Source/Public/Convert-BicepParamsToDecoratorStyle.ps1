function Convert-BicepParamsToDecoratorStyle {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,
            ParameterSetName = 'Default')]
        [ValidateNotNullOrEmpty()]
        [string]$Path,
        [Parameter(ParameterSetName = 'Default')]
        [switch]$ToClipboard
    )

    begin {
        $FileResolver = [Bicep.Core.FileSystem.FileResolver]::new()
        $ResourceProvider = [Bicep.Core.TypeSystem.Az.AzResourceTypeProvider]::new()
        $tempPath = [System.Io.Path]::GetTempPath()
    }

    process {
        $armHashTable = Build-Bicep -Path $Path -AsHashtable -IgnoreDiagnostics
        if (!$armHashTable) {
            Write-Error "Invalid bicep file provided as input. Fix all build errors and try again."
        }
        $paramHashTable = $armHashTable.parameters
        
        $parameters = [ordered]@{}
        $templateBase = [ordered]@{
            '$schema'        = 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
            'contentVersion' = '1.0.0.0'
        }
        $parameters = $paramHashTable
        $templateBase['parameters'] = $parameters
        $tempTemplate = ConvertTo-Json -InputObject $templateBase -Depth 100
        Out-File -InputObject $tempTemplate -FilePath "$tempPath\tempfile.json"
        $file = Get-ChildItem -Path "$tempPath\tempfile.json"

        if ($file) {
            $BicepObject = [Bicep.Decompiler.TemplateDecompiler]::DecompileFileWithModules($ResourceProvider, $FileResolver, $file.FullName)
            foreach ($BicepFile in $BicepObject.Item2.Keys) {
                $bicepData = $BicepObject.Item2[$BicepFile]
            }
            if ($ToClipboard.IsPresent) {
                Set-Clipboard $bicepData
                Write-Host "Decorator style params saved to clipboard"
            }
            else {
                Write-Host $bicepData
            }
        }
        Remove-Item $file
    }
}