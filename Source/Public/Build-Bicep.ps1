<#
.SYNOPSIS
    Compiles bicep files to JSON ARM Templates
.DESCRIPTION
    Build-Bicep is equivalent to bicep build but with the possibility to compile all .bicep files in a directory.
.PARAMETER Path
    Specfies the path to the directory or file that should be compiled
.PARAMETER OutputDirectory
    Specfies the path to the directory where the compiled files should be outputted
.PARAMETER ExcludeFile
    Specifies a .bicep file to exclude from compilation
.PARAMETER GenerateParameterFile
    The -GenerateParameterFile switch generates a ARM Template paramter file for the compiled template
.PARAMETER AsString
    The -AsString prints all output as a string instead of corresponding files. 
.EXAMPLE
    Build-Bicep -Path vnet.bicep
    Compile single bicep file in working directory
.EXAMPLE
    Build-Bicep -Path 'c:\bicep\modules\vnet.bicep'
    Compile single bicep file in different directory
.EXAMPLE
    Build-Bicep
    Compile all .bicep files in working directory
.EXAMPLE
    Build-Bicep -Path 'c:\bicep\modules\'
    Compile all .bicep files in different directory
.EXAMPLE
    Build-Bicep -ExcludeFile vnet.bicep
    Compile all .bicep files in the working directory except vnet.bicep
.EXAMPLE
    Build-Bicep -Path 'c:\bicep\modules\' -ExcludeFile vnet.bicep
    Compile all .bicep files in different directory except vnet.bicep
.EXAMPLE
    Build-Bicep -GenerateParameterFile
    Compile all .bicep files in the working directory and generates a parameter files
.NOTES
    Go to module repository https://github.com/StefanIvemo/BicepPowerShell for detailed info, reporting issues and to submit contributions.
#>
function Build-Bicep {
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [Alias('Invoke-BicepBuild')]
    param (
        [Parameter(ParameterSetName = 'Default',Position=1)]
        [Parameter(ParameterSetName = 'AsString',Position=1)]
        [string]$Path = $pwd.path,

        [Parameter(ParameterSetName = 'Default',Position=2)]
        [Parameter(ParameterSetName = 'AsString',Position=2)]
        [ValidateNotNullOrEmpty()]
        [string]$OutputDirectory,

        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'AsString')]
        [string[]]$ExcludeFile,

        [Parameter(ParameterSetName = 'Default')]
        [switch]$GenerateParameterFile,

        [Parameter(ParameterSetName = 'AsString')]
        [switch]$AsString
    )

    begin {
        if ($PSBoundParameters.ContainsKey('OutputDirectory') -and (-not (Test-Path $OutputDirectory))) {
            $null = New-Item $OutputDirectory -Force -ItemType Directory
        }
    }

    process {
        $files = Get-Childitem -Path $Path *.bicep -File
        if ($files) {
            foreach ($file in $files) {
                if ($file.Name -notin $ExcludeFile) {
                    $ARMTemplate = ParseBicep -Path $file.FullName
                    if ($AsString.IsPresent) {
                        Write-Output $ARMTemplate
                    }
                    else {        
                        if($PSBoundParameters.ContainsKey('OutputDirectory')) {
                            $OutputFilePath = Join-Path -Path $OutputDirectory -ChildPath ('{0}.json' -f $file.BaseName)
                        }
                        else {
                            $OutputFilePath = $file.FullName -replace '\.bicep','.json'
                        }
                        $null = Out-File -Path $OutputFilePath -InputObject $ARMTemplate -Encoding utf8
                        if ($GenerateParameterFile.IsPresent) {
                            GenerateParameterFile -Content $ARMTemplate
                        }
                    }
                }
            }
        }
        else {
            Write-Host "No bicep files located in path $Path"
        }
    }

}

