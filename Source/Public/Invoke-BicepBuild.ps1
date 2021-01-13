<#
.SYNOPSIS
    Compiles bicep files to JSON ARM Templates
.DESCRIPTION
    Invoke-BicepBuild is equivalent to bicep build but with the possibility to compile all .bicep files in a directory.
.PARAMETER Path
    Specfies the path to the directory or file that should be compiled
.EXAMPLE
    Invoke-BicepBuild vnet.bicep
    Compile single bicep file in working directory
.EXAMPLE
    Invoke-BicepBuild 'c:\bicep\modules\vnet.bicep'
    Compile single bicep file in different directory
.EXAMPLE
    Invoke-BicepBuild
    Compile all .bicep files in working directory
.EXAMPLE
    Invoke-BicepBuild -Path 'c:\bicep\modules\'
    Compile all .bicep files in different directory
.NOTES
    Go to module repository https://github.com/StefanIvemo/BicepPowerShell for detailed info, reporting issues and to submit contributions.
#>
function Invoke-BicepBuild {
    param(
        [string]$Path = $pwd.path
    )
    
    if (TestBicep) {
        $files = Get-Childitem -Path $Path *.bicep -File
        if ($files) {
            foreach ($file in $files) {
                bicep build $file
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