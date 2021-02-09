# Bicep - PowerShell Module

This is the repo for the Bicep PowerShell Module. The module is created using the [Bicep CLI](https://github.com/Azure/bicep) assemblies. It started with a simple function to enable compilation of all bicep files in a folder, but I came up with additional use cases and the Bicep Module was born.

Commands implemented:

- [Build-Bicep](./Docs/Build-Bicep.md)
- [ConvertTo-Bicep](./Docs/ConvertTo-Bicep.md)
- [Get-BicepVersion](./Docs/Get-BicepVersion.md)
- [Install-BicepCLI](./Docs/Install-BicepCLI.md)
- [Update-BicepCLI](./Docs/Update-BicepCLI.md)
- [Uninstall-BicepCLI](./Docs/Uninstall-BicepCLI.md)

>**Note:** Starting with version `1.3.0` of the Bicep PowerShell module the cmdlets `Build-Bicep` and `ConvertTo-Bicep` use the assemblies from the official [Bicep](https://github.com/Azure/bicep) repository instead of wrapping the Bicep CLI. The module currently runs on the assemblies from Bicep `version 0.2.328`. When new Bicep versions are released there will be some delay before the PowerShell module gets tested updated with the latest assemblies. If new functionality is added to Bicep CLI before the PowerShell module supports it, use `Install-BicepCLI` to install the latest Bicep CLI version and use the CLI while waiting for an updated PowerShell module.

## Installation

The Bicep PowerShell Module is published to [PowerShell Gallery](https://www.powershellgallery.com/packages/Bicep/).

```powershell
Install-Module -Name Bicep
```

## Bug report and feature requests

If you find a bug or have an idea for a new feature create an issue in the repo. This is also the place where you can see any planned features along with the projects tab.

## Contribution

If you like the Bicep PowerShell module and want to contribute you are very much welcome to do so. Please create an issue before you start working with a brand new feature to make sure that it’s not already in the works or that the idea has been dismissed already. There is also a number of issues up for grabs, if there is no one assigned to the issue, comment and let us know you've started working on it.

## Maintainers

This project is currently maintained by the following coders:

- [StefanIvemo](https://github.com/StefanIvemo)
- [SimonWahlin](https://github.com/SimonWahlin)
- [bjompen](https://github.com/bjompen)
- [JohnRoos](https://github.com/JohnRoos)
- [PalmEmanuel](https://github.com/PalmEmanuel)