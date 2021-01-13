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