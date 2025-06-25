# ![BicepIcon] PSBicep - Bicep PowerShell Module

[![Bicep]][BicepGallery] [![BicepDownloads]][BicepGallery]

This is the repository for the Bicep PowerShell Module. This is a community project created to enable the features provided by the [Bicep CLI](https://github.com/Azure/bicep) in PowerShell. The module provides the same functionality as Bicep CLI, plus some additional features to simplify the Bicep authoring experience.

>**Note:** When new Bicep versions are released there will be a slight delay before the PowerShell module gets tested updated with the latest assemblies. If new functionality is added to Bicep CLI before the PowerShell module supports it, use `Install-BicepCLI` to install the latest Bicep CLI version and use the CLI while waiting for an updated PowerShell module.

Commands implemented:

- [Build-Bicep](./Docs/Help/Build-Bicep.md)
- [Build-BicepParam](./Docs/Help/Build-BicepParam.md)
- [Clear-BicepModuleCache](./Docs/Help/Clear-BicepModuleCache.md)
- [Connect-Bicep](./Docs/Help/Connect-Bicep.md)
- [Convert-BicepParamsToDecoratorStyle](./Docs/Help/Convert-BicepParamsToDecoratorStyle.md)
- [Convert-JsonToBicep](./Docs/Help/Convert-JsonToBicep.md)
- [ConvertTo-Bicep](./Docs/Help/ConvertTo-Bicep.md)
- [Export-BicepResource](./Docs/Help/Export-BicepResource.md)
- [Export-BicepChildResource (**experimental**)](./Docs/Help/Export-BicepChildResource.md)
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

Due to the separation of code in C# and PowerShell, we currently depend on two different authentication models. Any feature that relies on built-in functionality in Bicep uses the authentication set in bicepconfig.json while Export-BicepResource uses PSBicep authentication depending on the module AzAuth and uses the command Connect-Bicep to log in.

We hope to use Connect-Bicep as default for all commands in the future.

The following commands will communicate with Azure and requires authentication:

- [Connect-Bicep](./Docs/Help/Connect-Bicep.md)
- [Export-BicepResource](./Docs/Help/Export-BicepResource.md)
- [Export-BicepChildResource](./Docs/Help/Export-BicepChildResource.md)
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
