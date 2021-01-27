<#
.SYNOPSIS
    Restore bicep module dependencies, like dotnet restore for bicep.
.DESCRIPTION
    When using bicep modules in a project, it is likely that the same module
    is reused in several projects. For example a module for creating a KeyVault.

    When improving a module that is used in several places, updating it everywhere
    quickly becomes a hassle. This is where Restore-Bicep is helpful!

    Instead of manually copying the correct version of a module to every place it
    is used, simply create a JSON file along with your bicep-file that declares any
    module dependencies, thier version and which repository they are available at.
    
    Before running bicep build, run Bicep-Resore and point it to the JSON file
    to download the right version of any dependency declared.

    Restore-Bicep currently only has the one dependency provider "RelativePath" which
    will copy a dependency from a path relative to the dependency file.

    RelativePath currently has support for versions in the convention 
    <ApiVersion>-<moduleVersion> and will search for a dependency in the source folder
    with the following pattern: <source>\<ApiVersion>\<name>-<moduleVersion>.bicep.

    Restore-Bicep can be extended with new providers by loading a class named 
    "BicepRestoreParametersProviderName" in the global scope. The class needs to:
    * inherit from BicepRestoreParametersBase
    * have a constructor with signature: BicepRestoreParametersProviderName([object]$Object, [string]$BasePath)
    * implement the method: [string] Restore($Path)

    To load a class in global scope, either dotsource a file or add the file
    as a "ScriptsToProcess" in a module manifest.

.EXAMPLE
    Dependency file in path C:\bicep\myProject\myTemplate\dependencies.json:
    [
        {
            "Name": "keyVault",
            "Version": "2019-09-01-1",
            "Type": "RelativePath",
            "Source": "../../Modules/keyVault"
        }
    ]
    PS C:\> Restore-Bicep -Path .\dependencies.json -DestinationPath modules

    Will look up file C:\bicep\Modules\keyVault\2019-09-01\keyVault-1.bicep and copy it
    to C:\bicep\myProject\myTemplate\modules\keyVault.bicep. To update dependencies to
    a later version, simply change the version and run Restore-Bicep again.
#>
function Restore-Bicep {
    [cmdletbinding()]
    param (
        # Path to dependency file. Has to be JSON and follow the format:
        # [
        #     {
        #         "Name": "<modulename>",
        #         "Version": "<version of module, standard decided by provider>",
        #         "Type": "<name of dependency provider>",
        #         "Source": "<a source path, standard decided by provider>"
        #     }
        # ]
        [Parameter(ValueFromPipeline)]
        $Path,

        # Folder where modules will be downloaded to relative to dependency file.
        # Use empty string to download to same folder as dependency file.
        [AllowEmptyString()]
        $DestinationPath = 'modules'
    )
    begin {
        Write-Warning -Message "Restore-Bicep is in preview and might experience breaking changes, use with caution."
    }
    process {
        $Path = Resolve-Path -Path $Path | Select-Object -ExpandProperty 'Path'
        $BasePath = Split-Path -Path $Path -Parent

        Write-Verbose -Message "Reading path configuration from: $Path"
        $Resources = Get-Content -Path $Path -ErrorAction 'Stop' | ConvertFrom-Json
        foreach ($resource in $Resources) {
            $Provider = ConvertTo-BicepRestoreParameter -Resource $resource -BasePath $BasePath
            
            $Provider.Restore($DestinationPath)
        }
    }
}
