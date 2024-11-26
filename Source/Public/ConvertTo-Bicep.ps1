function ConvertTo-Bicep {
    [CmdletBinding(DefaultParameterSetName = 'Decompile')]
    param(
        [Parameter(ParameterSetName = 'Decompile')]
        [string]$Path = $pwd.path,
        
        [Parameter(ParameterSetName = 'Decompile')]
        [string]$OutputDirectory,
        
        [Parameter(ParameterSetName = 'Decompile')]
        [switch]$AsString,
        
        [Parameter(ParameterSetName = 'Decompile')]
        [switch]$Force,

        [Parameter(Mandatory, ParameterSetName = 'ConvertFromBody')]
        [string]$ResourceId,
        
        [Parameter(Mandatory, ParameterSetName = 'ConvertFromBody')]
        [string]$ResourceBody
    )

    begin {
        if ($PSCmdlet.ParameterSetName -eq 'Decompile') {
            Write-Warning -Message 'Decompilation is a best-effort process, as there is no guaranteed mapping from ARM JSON to Bicep.
You may need to fix warnings and errors in the generated bicep file(s), or decompilation may fail entirely if an accurate conversion is not possible.
If you would like to report any issues or inaccurate conversions, please see https://github.com/Azure/bicep/issues.'
            
            if ($PSBoundParameters.ContainsKey('OutputDirectory') -and (-not (Test-Path $OutputDirectory))) {
                $null = New-Item $OutputDirectory -Force -ItemType Directory
            }
        }  
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq 'Decompile') {
            $files = Get-Childitem -Path $Path -Filter '*.json' -File | Select-String -Pattern "schema.management.azure.com/schemas/.*deploymentTemplate.json#" | Select-Object -ExpandProperty 'Path' 
            if ($files) {
                foreach ($File in $files) {
                    $BicepObject = ConvertTo-BicepFile -Path $File
                    foreach ($BicepFile in $BicepObject.Keys) {
                        if ($AsString.IsPresent) {
                            Write-Output $BicepObject[$BicepFile]
                            $TempFolder = New-Item -Path ([system.io.path]::GetTempPath()) -Name (New-Guid).Guid -ItemType 'Directory'
                            $OutputDirectory = $TempFolder.FullName
                        }

                        if (-not [string]::IsNullOrEmpty($OutputDirectory)) {
                            $FileName = Split-Path -Path $BicepFile -Leaf
                            $FilePath = Join-Path -Path $OutputDirectory -ChildPath $FileName
                        }
                        else {
                            $FilePath = $BicepFile
                        }
                    
                        if ((Test-Path $FilePath) -and (-not $Force)) {
                            Write-Error -Message "$FilePath Already exists. Use -Force to overwrite." -Category ResourceExists -TargetObject $FilePath
                            $VerifyBicepBuild = $false
                        }
                        else {
                            $null = Out-File -InputObject $BicepObject[$BicepFile] -FilePath $FilePath -Encoding utf8
                            $VerifyBicepBuild = $true
                        }
                    }
                
                    if ($VerifyBicepBuild) {
                        $null = Build-Bicep -Path $FilePath -AsString
                    }

                    if ($null -ne $TempFolder) {
                        Remove-Item -Path $TempFolder -Recurse -Force
                    }
                }
            }
            else {
                Write-Host "No ARM template files located in path $Path"
            }
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'ConvertFromBody') {
            Convert-ARMResourceToBicep -ResourceId $ResourceId -ResourceBody $ResourceBody
        }
        else {
            throw [System.Exception.NotimplementedException]::new()
        }
    }
}