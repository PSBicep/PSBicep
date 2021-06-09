# ![BicepIcon] Bicep - PowerShell Module

[![Bicep]][BicepGallery] [![BicepDownloads]][BicepGallery]

This is the repository for the Bicep PowerShell Module. This is a community project created to enable the features provided by the [Bicep CLI](https://github.com/Azure/bicep) in PowerShell. The module provides the same functionality as Bicep CLI, plus some additional features to simplify the Bicep authoring experience.

Commands implemented:

- [Build-Bicep](./Docs/Help/Build-Bicep.md)
- [ConvertTo-Bicep](./Docs/Help/ConvertTo-Bicep.md)
- [Get-BicepVersion](./Docs/Help/Get-BicepVersion.md)
- [Get-BicepApiReference](./Docs/Help/Get-BicepApiReference.md)
- [Install-BicepCLI](./Docs/Help/Install-BicepCLI.md)
- [Update-BicepCLI](./Docs/Help/Update-BicepCLI.md)
- [Uninstall-BicepCLI](./Docs/Help/Uninstall-BicepCLI.md)
- [Update-BicepTypes](./Docs/Help/Update-BicepTypes.md)
- [Convert-JsonToBicep](./Docs/Help/Convert-JsonToBicep.md)
- [New-BicepParameterFile](./Docs/Help/New-BicepParameterFile.md)
- [Convert-BicepParamsToDecoratorStyle](./Docs/Help/Convert-BicepParamsToDecoratorStyle.md) (Decommissioned in `v1.5.0`)

>**Note:** Starting with version `1.3.0` of the Bicep PowerShell module the cmdlets `Build-Bicep` and `ConvertTo-Bicep` uses the assemblies from the official [Bicep](https://github.com/Azure/bicep) repository instead of wrapping the Bicep CLI. When new Bicep versions are released there will be a slight delay before the PowerShell module gets tested updated with the latest assemblies. If new functionality is added to Bicep CLI before the PowerShell module supports it, use `Install-BicepCLI` to install the latest Bicep CLI version and use the CLI while waiting for an updated PowerShell module.

## Installation

The Bicep PowerShell Module is published to [PowerShell Gallery](https://www.powershellgallery.com/packages/Bicep/).

```powershell
Install-Module -Name Bicep
```

>**Note:** If you want to test the latest features before we've release it to PowerShell Gallery, see the [Contribution Guide](CONTRIBUTING.md) for instructions on how to manually download the dependencies and install the module manually.

## Bug report and feature requests

If you find a bug or have an idea for a new feature create an issue in the repo. Please have a look and see if a similar issue is already created before submitting.

## Contribution

If you like the Bicep PowerShell module and want to contribute you are very much welcome to do so. Please read our [Contribution Guide](CONTRIBUTING.md) before you start! ❤

## Maintainers

This project is currently maintained by the following coders:

- [StefanIvemo](https://github.com/StefanIvemo)
- [SimonWahlin](https://github.com/SimonWahlin)
- [bjompen](https://github.com/bjompen)
- [JohnRoos](https://github.com/JohnRoos)
- [PalmEmanuel](https://github.com/PalmEmanuel)
- [emilguden](https://github.com/emilguden)

<!-- References -->
[BicepIcon]: logo/BicePS_40px.png
[Bicep]: https://img.shields.io/badge/Bicep-v1.5.0-blue
[BicepDownloads]: https://img.shields.io/powershellgallery/dt/Bicep
[BicepGallery]: https://www.powershellgallery.com/packages/Bicep/
