function ConvertTo-Bicep {
    [CmdletBinding()]
    param(
        [string]$Path = $pwd.path,
        
        [string]$OutputDirectory,

        [string]$ARMSnippet,

        [switch]$AsString
    )

    begin {
        if ([string]::IsNullOrWhiteSpace($ARMSnippet)) {
            Write-Warning -Message 'Decompilation is a best-effort process, as there is no guaranteed mapping from ARM JSON to Bicep.
You may need to fix warnings and errors in the generated bicep file(s), or decompilation may fail entirely if an accurate conversion is not possible.
If you would like to report any issues or inaccurate conversions, please see https://github.com/Azure/bicep/issues.'
        }
        if ($PSBoundParameters.('ContainsKeyOutputDirectory') -and (-not (Test-Path $OutputDirectory))) {
            $null = New-Item $OutputDirectory -Force -ItemType Directory
        }
        
        $FileResolver = [Bicep.Core.FileSystem.FileResolver]::new()
        $ResourceProvider = [Bicep.Core.TypeSystem.Az.AzResourceTypeProvider]::new()
    }

    process {
        if ($PSBoundParameters.ContainsKey('ARMSnippet')) {
            $jsonObject = ConvertFrom-Json -InputObject $ARMSnippet -AsHashtable -Depth 100
            $variables = [ordered]@{}
            $templateBase = [ordered]@{
                '$schema'        = 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
                'contentVersion' = '1.0.0.0'
            }
            $variables['temp'] = $jsonObject                                  
            $templateBase['variables'] = $variables
            $tempTemplate = ConvertTo-Json -InputObject $templateBase -Depth 100
            Out-File -InputObject $tempTemplate -FilePath "$($env:TEMP)\tempfile.json"
            $files = Get-ChildItem -Path "$($env:TEMP)\tempfile.json"
        }
        else {
            $files = Get-Childitem -Path $Path -Filter '*.json' -File
        }    
    
        if ($files) {
            foreach ($file in $files) {
                $BicepObject = [Bicep.Decompiler.TemplateDecompiler]::DecompileFileWithModules($ResourceProvider, $FileResolver, $file.FullName)
                
                foreach ($BicepFile in $BicepObject.Item2.Keys) {
                    if ($AsString.IsPresent) {
                        Write-Output $BicepObject.Item2[$BicepFile]
                    }
                    elseif ($PSBoundParameters.ContainsKey('ARMSnippet')) {
                        $bicepData = $BicepObject.Item2[$BicepFile]
                    }
                    else {
                        if ($PSBoundParameters.ContainsKey('OutputDirectory')) {
                            $FileName = Split-Path -Path $BicepFile.AbsolutePath -Leaf
                            $FilePath = Join-Path -Path $OutputDirectory -ChildPath $FileName
                        }
                        else {
                            $FilePath = $BicepFile.AbsolutePath
                        }
                        $null = Out-File -InputObject $BicepObject.Item2[$BicepFile] -FilePath $FilePath -Encoding utf8
                    }
                }

                if ($PSBoundParameters.ContainsKey('ARMSnippet')) {
                    $bicepOutput = $bicepData.Replace("var temp = ", "")
                    Write-Host $bicepOutput
                }
                else {
                    if ($PSBoundParameters.ContainsKey('OutputDirectory')) {
                        $FileName = Split-Path -Path $BicepObject.Item1.AbsolutePath -Leaf
                        $FilePath = Join-Path -Path $OutputDirectory -ChildPath $FileName
                    }
                    else {
                        $FilePath = $BicepObject.Item1.AbsolutePath
                    }
                    $null = Build-Bicep -Path $FilePath -AsString
                }                
            }
        }
        else {
            Write-Host "No bicep files located in path $Path"
        }
    }
}