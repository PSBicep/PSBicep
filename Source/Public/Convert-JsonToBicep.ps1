function Convert-JsonToBicep {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,
            ValueFromPipeline = $true,
            ParameterSetName = 'String')]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                try { $_ | Convertfrom-Json }
                catch { $false }
            },
            ErrorMessage = 'The string is not a valid json')]
        [string]$String
    )

    begin {
        $FileResolver = [Bicep.Core.FileSystem.FileResolver]::new()
        $ResourceProvider = [Bicep.Core.TypeSystem.Az.AzResourceTypeProvider]::new()
        $tempPath = [System.Io.Path]::GetTempPath()
    }

    process {
        $jsonObject = ConvertFrom-Json -InputObject $String -AsHashtable -Depth 100
        $variables = [ordered]@{}
        $templateBase = [ordered]@{
            '$schema'        = 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
            'contentVersion' = '1.0.0.0'
        }
        $variables['temp'] = $jsonObject
        $templateBase['variables'] = $variables
        $tempTemplate = ConvertTo-Json -InputObject $templateBase -Depth 100
        Out-File -InputObject $tempTemplate -FilePath "$tempPath\tempfile.json"
        $file = Get-ChildItem -Path "$tempPath\tempfile.json"

        if ($file) {
            $BicepObject = [Bicep.Decompiler.TemplateDecompiler]::DecompileFileWithModules($ResourceProvider, $FileResolver, $file.FullName)
            foreach ($BicepFile in $BicepObject.Item2.Keys) {
                $bicepData = $BicepObject.Item2[$BicepFile]
            }
            $bicepOutput = $bicepData.Replace("var temp = ", "")
            Write-Host $bicepOutput
        }
        Remove-Item $file
    }
}