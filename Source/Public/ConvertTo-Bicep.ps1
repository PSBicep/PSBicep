<#
.SYNOPSIS
    Decompile ARM templates to Bicep
.DESCRIPTION
    ConvertTo-Bicep is equivalent to 'bicep decompile' but with the possibility to decompile all .bicep files in a directory.
.PARAMETER Path
    Specfies the path to the directory or file that should be decompiled
.EXAMPLE
    ConvertTo-Bicep vnet.json
    Decompile single json file in working directory
.EXAMPLE
    ConvertTo-Bicep 'c:\armtemplates\vnet.json'
    Decompile single json file in provided directory
.EXAMPLE
    ConvertTo-Bicep
    Decompile all .json files in working directory
.EXAMPLE
    ConvertTo-Bicep -Path 'c:\armtemplates\'
    Decompile all .json files in different directory
.NOTES
    Go to module repository https://github.com/StefanIvemo/BicepPowerShell for detailed info, reporting issues and to submit contributions.
#>
function ConvertTo-Bicep {
    [CmdletBinding()]
    param(
        [string]$Path = $pwd.path,
        
        [string]$OutputDirectory = $pwd.path,

        [switch]$AsString
    )

    begin {
        if (-not (Test-Path $OutputDirectory)) {
            New-Item $OutputDirectory -Force -ItemType Directory
        }
        
        $FileResolver = [Bicep.Core.FileSystem.FileResolver]::new()
        $ResourceProvider = [Bicep.Core.TypeSystem.Az.AzResourceTypeProvider]::new()
    }

    process {
        $files = Get-Childitem -Path $Path *.json -File
        if ($files) {
            foreach ($file in $files) {
                $BicepObject = [Bicep.Decompiler.TemplateDecompiler]::DecompileFileWithModules($ResourceProvider, $FileResolver, $file.FullName)
                
                foreach ($BicepFile in $BicepObject.Item2.Keys) {
                    if ($AsString.IsPresent) {
                        Write-Output $BicepObject.Item2[$BicepFile]
                    }
                    else {
                        $FileName = Split-Path -Path $BicepFile -Leaf
                        $FilePath = Join-Path -Path $OutputDirectory -ChildPath $FileName
                        $null = Out-File -InputObject $BicepObject.Item2[$BicepFile] -FilePath $FilePath -Encoding utf8
                    }
                }
            }
        }
        else {
            Write-Host "No bicep files located in path $Path"
        }
    }
}