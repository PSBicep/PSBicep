# ![BicepIcon] PSBicep - Bicep PowerShell Module

[![Bicep]][BicepGallery] [![BicepDownloads]][BicepGallery]

This is the repository for the Bicep PowerShell Module. This is a community project created to enable the features provided by the [Bicep CLI](https://github.com/Azure/bicep) in PowerShell. The module provides the same functionality as Bicep CLI, plus some additional features to simplify the Bicep authoring experience.

>**Note:** When new Bicep versions are released there will be a slight delay before the PowerShell module gets tested updated with the latest assemblies. If new functionality is added to Bicep CLI before the PowerShell module supports it, use `Install-BicepCLI` to install the latest Bicep CLI version and use the CLI while waiting for an updated PowerShell module.

## Features
Here are a few features (other than just a native PowerShell experience) that sets the Bicep PowerShell module apart from using the official Bicep CLI.

### Build and convert Bicep templates
    Build Bicep templates to ARM templates and convert ARM templates to Bicep. Build-Bicep supports various output formats such as file, string and hashtable. Use a directory as input to build all Bicep templates in the directory.

    Since all required Bicep assemblies are loaded into memory with the module, the build commands are very fast which is especially useful when building a large number of Bicep templates in a for example a pipeline.

### Export Azure resources as bicep templates
    Export Azure resources as deployable bicep templates using Export-BicepResource. Find resources to export using a KQL query to search Azure Resource Graph or a list of ResourceIds. Using a KQL query in combination with the parameter `-UseKQLResult` treat the output from Azure Resource Graph as a resource body used to generate a bicep template. This is a very performant way to export large quantities of resources. The parameter `-RemoveUnknownProperties` will append a custom rewriter that will remove any property not found in the latest known type definition, this helps clean up templates but has a small risk of removing properties not found in the type definition schema. Use `-IncludeTargetScope` when exporting resources that live outside of a ResourceGroup to append a targetScope declaration on the first line of each template.

    By default, the command outputs a hashtable where the resourceId is the key and the template is the value, but using the parameter `-AsString` will cause the command to only output templates as strings, this can for example be useful when exporting several resources to one file.

### Generate markdown documentation from bicep templates
    The command `New-BicepMarkdownDocumentation` will generate a markdown document in the same folder as a bicep file containing documentation of, for example, the providers, resources, parameters variables and outputs of a template.

## Commands implemented

- [Build-Bicep](./Docs/Help/Build-Bicep.md)
- [Build-BicepParam](./Docs/Help/Build-BicepParam.md)
- [Clear-BicepModuleCache](./Docs/Help/Clear-BicepModuleCache.md)
- [Connect-Bicep](./Docs/Help/Connect-Bicep.md)
- [Convert-BicepParamsToDecoratorStyle](./Docs/Help/Convert-BicepParamsToDecoratorStyle.md)
- [Convert-JsonToBicep](./Docs/Help/Convert-JsonToBicep.md)
- [ConvertTo-Bicep](./Docs/Help/ConvertTo-Bicep.md)
- [Export-BicepResource](./Docs/Help/Export-BicepResource.md)
- [Find-BicepModule](./Docs/Help/Find-BicepModule.md)
- [Format-BicepFile](./Docs/Help/Format-BicepFile.md)
- [Get-BicepApiReference](./Docs/Help/Get-BicepApiReference.md)
- [Get-BicepConfig](./Docs/Help/Get-BicepConfig.md)
- [Get-BicepMetadata](./Docs/Help/Get-BicepMetadata.md)
- [Get-BicepUsedModules](./Docs/Help/Get-BicepUsedModules.md)
- [Get-BicepVersion](./Docs/Help/Get-BicepVersion.md)
- [Install-BicepCLI](./Docs/Help/Install-BicepCLI.md)
- [New-BicepMarkdownDocumentation](./Docs/Help/New-BicepMarkdownDocumentation.md)
- [New-BicepParameterFile](./Docs/Help/New-BicepParameterFile.md)
- [Publish-Bicep](./Docs/Help/Publish-Bicep.md)
- [Restore-Bicep](./Docs/Help/Restore-Bicep.md)
- [Test-BicepFile](./Docs/Help/Test-BicepFile.md)
- [Uninstall-BicepCLI](./Docs/Help/Uninstall-BicepCLI.md)
- [Update-BicepCLI](./Docs/Help/Update-BicepCLI.md)
- [Update-BicepParameterFile](./Docs/Help/Update-BicepParameterFile.md)
- [Update-BicepTypes](./Docs/Help/Update-BicepTypes.md)

## Authentication

Use Connect-Bicep to create an authentication context for Bicep. If no context is created, Bicep will try to use the context from Azure PowerShell.

The following commands will communicate with Azure and requires authentication:

- [Connect-Bicep](./Docs/Help/Connect-Bicep.md)
- [Export-BicepResource](./Docs/Help/Export-BicepResource.md)
- [Publish-Bicep](./Docs/Help/Publish-Bicep.md)
- [Restore-Bicep](./Docs/Help/Restore-Bicep.md)

## Installation

The Bicep PowerShell Module is published to [PowerShell Gallery](https://www.powershellgallery.com/packages/Bicep/).

```powershell
Install-Module -Name Bicep
```

### Pre-release versions

To install the latest version in development use the `-AllowPrerelease` switch.

```powershell
Install-Module -Name Bicep -AllowPrerelease
```

>**Note:** If you want to test the latest features before we've release it to PowerShell Gallery, see the [Contribution Guide](CONTRIBUTING.md) for instructions on how to manually download the dependencies and install the module manually.

## Bug report and feature requests

If you find a bug or have an idea for a new feature create an issue in the repo. Please have a look and see if a similar issue is already created before submitting.

## Contribution

If you like the Bicep PowerShell module and want to contribute you are very much welcome to do so. Please read our [Contribution Guide](CONTRIBUTING.md) before you start! ❤

## Maintainers

This project is actively maintained by the following coders:

- [SimonWahlin](https://github.com/SimonWahlin)
- [PalmEmanuel](https://github.com/PalmEmanuel)
- [StefanIvemo](https://github.com/StefanIvemo)

<!-- References -->
[BicepIcon]: logo/BicePS_40px.png
[Bicep]: https://img.shields.io/badge/Bicep-v2.9.1-blue
[BicepDownloads]: https://img.shields.io/powershellgallery/dt/Bicep
[BicepGallery]: https://www.powershellgallery.com/packages/Bicep/
