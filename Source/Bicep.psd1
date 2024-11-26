#
# Module manifest for module 'Bicep'
#
# Generated by: StefanIvemo
#
# Generated on: 2021-01-12
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'Bicep.psm1'

# Version number of this module.
ModuleVersion = '2.3.3'

# Supported PSEditions
CompatiblePSEditions = @('Core')

# ID used to uniquely identify this module
GUID = 'dfce7d56-54cc-46df-8be8-2518093e803f'

# Author of this module
Author = 'Stefan Ivemo'

# Company or vendor of this module
# CompanyName = 'Unknown'

# Copyright statement for this module
Copyright = '(c) Stefan Ivemo. All rights reserved.'

# Description of the functionality provided by this module
Description = 'A module to run Bicep using PowerShell. The module is a community project built using the Bicep assemblies to provide you with an enhanced Bicep experience directly from PowerShell without having Bicep CLI installed. 

The module also provides the additional features:
- Generate ARM template parameter files directly from a Bicep file
- Quickly open the API reference docs by referencing the Bicep types
- Get the result from a build as a string or hashtable instead of writing to a file
- Test if a Bicep file is valid without building it
- Convert JSON objects to Bicep Language
- Install/Update/Uninstall Bicep CLI
- Specify output folder when building* and decompiling Bicep/ARM templates
- Specify output filename when building Bicep files
- Find modules in private module registries
- Clear local module cache

For more information about Bicep, please visit the official Bicep GitHub Repository:
https://github.com/Azure/bicep'

# Minimum version of the PowerShell engine required by this module
PowerShellVersion = '7.4'

# Name of the PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# ClrVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
RequiredModules = @(
    @{ModuleName = 'AzAuth'; ModuleVersion = '2.3.0'; MaximumVersion = '2.999.999'}
)

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
NestedModules = @('PSBicep/PSBicep.dll')

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = @(
    'Build-Bicep',
    'Build-BicepParam',
    'Clear-BicepModuleCache',
    'Convert-BicepParamsToDecoratorStyle',
    'Convert-JsonToBicep',
    'ConvertTo-Bicep',
    'Export-BicepResource',
    'Find-BicepModule',
    'Format-BicepFile',
    'Get-BicepApiReference',
    'Get-BicepMetadata',
    'Get-BicepUsedModules',
    'Get-BicepVersion', 
    'Install-BicepCLI', 
    'New-BicepMarkdownDocumentation',
    'New-BicepParameterFile',
    'Publish-Bicep',
    'Restore-Bicep',
    'Test-BicepFile',
    'Uninstall-BicepCLI', 
    'Update-BicepCLI', 
    'Update-BicepParameterFile',
    'Update-BicepTypes'
)


# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = @( 
    'Get-BicepConfig', 
    'Export-BicepChildResource'
)

# Variables to export from this module
VariablesToExport = ''

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = @('Invoke-BicepBuild')

# DSC resources to export from this module
# DscResourcesToExport = @()

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
# FileList = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @('azure', 'bicep', 'arm-json', 'arm-templates', 'windows', 'bicepnet', 'psbicep')

        # A URL to the license for this module.
        LicenseUri = 'https://github.com/PSBicep/PSBicep/blob/main/LICENSE'

        #A URL to the main website for this project.
        ProjectUri = 'https://github.com/PSBicep/PSBicep'

        # A URL to an icon representing this module.
        IconUri = 'https://raw.githubusercontent.com/PSBicep/PSBicep/main/logo/BicePS.png'

        # ReleaseNotes of this module
        ReleaseNotes = 'https://github.com/PSBicep/PSBicep/releases'

        # Prerelease string of this module
        Prerelease = ''

        # Flag to indicate whether the module requires explicit user acceptance for install/update/save
        # RequireLicenseAcceptance = $false

        # External dependent modules of this module
        # ExternalModuleDependencies = @()

    } # End of PSData hashtable

} # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}
