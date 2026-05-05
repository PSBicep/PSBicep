---
document type: module
Help Version: 1.0.0.0
HelpInfoUri: ''
Locale: en-US
Module Guid: dfce7d56-54cc-46df-8be8-2518093e803f
Module Name: Bicep
ms.date: 05/08/2026
PlatyPS schema version: 2024-05-01
title: Bicep Module
---

# Bicep Module

## Description

A module to run Bicep using PowerShell. The module is a community project built using the Bicep assemblies to provide you with an enhanced Bicep experience directly from PowerShell without having Bicep CLI installed.

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
https://github.com/Azure/bicep

## Bicep Cmdlets

### [Build-Bicep](Build-Bicep.md)

Builds one or more .bicep files.

### [Build-BicepParam](Build-BicepParam.md)

Builds one or more .bicepparam files.

### [Clear-BicepModuleCache](Clear-BicepModuleCache.md)

Clear the local module cache.

### [Connect-Bicep](Connect-Bicep.md)

Connect and sign in to Azure.

### [Convert-JsonToBicep](Convert-JsonToBicep.md)

Convert a JSON string or file to Bicep

### [ConvertTo-Bicep](ConvertTo-Bicep.md)

Decompile ARM templates to .bicep files

### [Disconnect-Bicep](Disconnect-Bicep.md)

Clears the current Azure authentication session for Bicep operations.

### [Export-BicepResource](Export-BicepResource.md)

Exports a specified Azure resource as Bicep.

### [Find-BicepModule](Find-BicepModule.md)

Command to list modules in private Bicep module registries (ACR).

### [Format-BicepFile](Format-BicepFile.md)

Format one or several Bicep files.

### [Get-BicepApiReference](Get-BicepApiReference.md)

Get ARM Template reference docs for provided resource type.

### [Get-BicepApiVersion](Get-BicepApiVersion.md)

Retrieve the API version for a Bicep resource type.

### [Get-BicepConfig](Get-BicepConfig.md)

Get bicep configuration (bicepconfig.json) in use for a bicep file.

### [Get-BicepMetadata](Get-BicepMetadata.md)

Get metadata from a Bicep template

### [Get-BicepUsedModules](Get-BicepUsedModules.md)

Get modules used in a Bicep file.

### [Get-BicepVersion](Get-BicepVersion.md)

View the installed version and the latest available version of Bicep CLI.

### [Install-BicepCLI](Install-BicepCLI.md)

Install Bicep CLI (Windows only)

### [New-BicepMarkdownDocumentation](New-BicepMarkdownDocumentation.md)

Create markdown documentation for bicep files

### [New-BicepParameterFile](New-BicepParameterFile.md)

Creates an ARM Template parameter file based on a bicep file.

### [Publish-Bicep](Publish-Bicep.md)

Publishes a .bicep file to the module registry.

### [Restore-Bicep](Restore-Bicep.md)

Restores external modules from the specified Bicep file to the local module cache.

### [Test-BicepFile](Test-BicepFile.md)

Tests if a bicep or bicepparam file is valid.

### [Uninstall-BicepCLI](Uninstall-BicepCLI.md)

Uninstall Bicep CLI (Windows only)

### [Update-BicepCLI](Update-BicepCLI.md)

Update Bicep CLI (Windows only)

### [Update-BicepParameterFile](Update-BicepParameterFile.md)

Updates existing ARM Template parameter file based on a bicep file.

### [Update-BicepTypes](Update-BicepTypes.md)

Update Bicep Types data

