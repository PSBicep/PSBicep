function ConvertTo-Bicep {
    [CmdletBinding()]
    param(
        [string]$Path = $pwd.path,
        
        [string]$OutputDirectory,

        [switch]$AsString
    )

    begin {
        if (-not $Script:ModuleVersionChecked) {
            TestModuleVersion
        }
        Write-Warning -Message 'Decompilation is a best-effort process, as there is no guaranteed mapping from ARM JSON to Bicep.
You may need to fix warnings and errors in the generated bicep file(s), or decompilation may fail entirely if an accurate conversion is not possible.
If you would like to report any issues or inaccurate conversions, please see https://github.com/Azure/bicep/issues.'
        
        if ($PSBoundParameters.ContainsKey('OutputDirectory') -and (-not (Test-Path $OutputDirectory))) {
            $null = New-Item $OutputDirectory -Force -ItemType Directory
        }
        
        $FileResolver = [Bicep.Core.FileSystem.FileResolver]::new()
        $ResourceProvider = [Bicep.Core.TypeSystem.Az.AzResourceTypeProvider]::CreateWithAzTypes()
    }

    process {
        $files = Get-Childitem -Path $Path -Filter '*.json' -File
        if ($files) {
            foreach ($file in $files) {
                $BicepObject = [Bicep.Decompiler.TemplateDecompiler]::DecompileFileWithModules($ResourceProvider, $FileResolver, $file.FullName)
                
                foreach ($BicepFile in $BicepObject.Item2.Keys) {
                    if ($AsString.IsPresent) {
                        Write-Output $BicepObject.Item2[$BicepFile]
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
        else {
            Write-Host "No bicep files located in path $Path"
        }
    }
}