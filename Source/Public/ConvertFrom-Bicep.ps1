<#
.SYNOPSIS
    Decompile ARM templates to Bicep
.DESCRIPTION
    ConvertFrom-Bicep is equivalent to 'bicep decompile' but with the possibility to decompile all .bicep files in a directory.
.PARAMETER Path
    Specfies the path to the directory or file that should be decompiled
.EXAMPLE
    ConvertFrom-Bicep vnet.json
    Decompile single json file in working directory
.EXAMPLE
    ConvertFrom-Bicep 'c:\armtemplates\vnet.json'
    Decompile single json file in provided directory
.EXAMPLE
    ConvertFrom-Bicep
    Decompile all .json files in working directory
.EXAMPLE
    ConvertFrom-Bicep -Path 'c:\armtemplates\'
    Decompile all .json files in different directory
.NOTES
    Go to module repository https://github.com/StefanIvemo/BicepPowerShell for detailed info, reporting issues and to submit contributions.
#>
function ConvertFrom-Bicep {
    param(
        [string]$Path = $pwd.path
    )

    if (TestBicep) {
        $files = Get-Childitem -Path $Path *.json -File
        if ($files) {
            foreach ($file in $files) {
                bicep decompile $file
            }   
        }
        else {
            Write-Host "No bicep files located in path $Path"
        } 
    }
    else {
        Write-Error "Cannot find the Bicep CLI. Install Bicep CLI using Install-BicepCLI."
    }    
}