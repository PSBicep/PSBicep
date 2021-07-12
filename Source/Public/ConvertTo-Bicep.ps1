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
        
    }

    process {
        $files = Get-Childitem -Path $Path -Filter '*.json' -File | Select-String -Pattern "schema.management.azure.com/schemas/.*deploymentTemplate.json#" | Select-Object Path 
        if ($files) {
            foreach ($file in $files) {
                $BicepObject = ConvertTo-BicepNetFile -Path $file.FullName
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
                    
                    $null = Out-File -InputObject $BicepObject[$BicepFile] -FilePath $FilePath -Encoding utf8
                }

                # if (-not [string]::IsNullOrEmpty($OutputDirectory)) {
                #     $FileName = Split-Path -Path $BicepObject.Item1.LocalPath -Leaf
                #     $FilePath = Join-Path -Path $OutputDirectory -ChildPath $FileName
                # }
                # else {
                #     $FilePath = $BicepObject.Item1.LocalPath
                # }
                $null = Build-Bicep -Path $FilePath -AsString

                if($null -ne $TempFolder) {
                    Remove-Item -Path $TempFolder -Recurse -Force
                }
            }
        }
        else {
            Write-Host "No ARM template files located in path $Path"
        }
    }
}