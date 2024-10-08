# Contributing to Bicep PowerShell

You are more than welcome to contribute to the Bicep PowerShell module, whether it is [Pull Requests](#pull-requests), [Feature Suggestions](#feature-suggestions) or [Bug Reports](#bug-reports)!

## Getting Started

- Fork this repo (see [this forking guide](https://guides.github.com/activities/forking/) for more information).
- Checkout the repo locally with `git clone git@github.com:{your_username}/PSBicep.git`.
- Run the command `.\build.ps1 -ResolveDependency -Task build` to download the required dependencies and build the module.

### Structure

The repo is organized into three codebases:

#### PSBicep.Core

This is a C# project that acts as a thin wrapper around Bicep. This project has a direct dependency on the Bicep project and will, once compiled, include all required assemblies from Bicep.

#### PSBicep

This is a PowerShell module written in C# than mainly has the responsibility of loading all assemblies from PSBicep.Core into a separate Assembly Load Context. This will let us import assemblies (DLLs) without risk of conflicts with other modules. PSBicep is loaded as a nested module.

#### Source

The Source folder contains the source code for the PowerShell module. This is the main part of the module and contains most of the commands that is exposed from the module. The Source folder is divided into the following subfolders:

- **Assets** (`Source/Assets`): Folder created by the build script. Contains jsonfile with information of BicepTypes.
- **Classes** (`Source/Classes`): Home of all the classes used by the module.
- **en-US** (`Source/en-US`): Module help file location. Generated by the build task `updateExternalHelp`using the module `PlatyPS` to generate XML based help from markdown help files in the Docs folder.
- **Private** (`Source/Private`): All private functions that are written in PowerShell and used by the module.
- **Public** (`Source/Public`): All functions that are written in PowerShell and exported by the module.
- **Tests** (`Tests`): Pester tests executed at Pull Request. Can be invoked by calling `./build.ps1 -Tasks test`
- **scripts** (`scripts`): Script file location used by Github Actions and to update assemblies when developing locally.
- **Help** (`Docs\Help`): Markdown help files for external help.

### Running the module locally

- Download the assemblies needed by the module by running the command `.\build.ps1 -ResolveDependency -Task build`. This will package the module to the path `output/Bicep`

```
.\build.ps1 -ResolveDependency -Task build
Import-Module ./output/Bicep
```

- Import the module directly from source. This can be handy for stepping through the source code.

```powershell
Import-Module .\Source\Bicep.psd1
```

### platyPS

[platyPS](https://github.com/PowerShell/platyPS) is used to write the external help in markdown. When contributing always make sure that the changes are added to the help file.  
A slightly modified version of platyPS is downloaded and used by the build script. The build script will also update markdown files and generate external help.

Make sure to edit the markdown file(s) in the `.\Docs\Help` folder and populate `{{ ... }}` placeholders with missed help content.

### Tests

[Pester](https://github.com/pester/Pester) is the ubiquitous test and mock framework for PowerShell. We use it for automatic testing and it executes at Pull Requests. We have a lot improvements to do on the test front and contributions are more than welcome. The progress can be tracked [here](https://github.com/PSBicep/PSBicep/issues/22).

## Pull Requests

If you like to start contributing to Bicep PowerShell. Please make sure that there is a related issue to link to your PR.

- All PRs should be tagged using the labels, `newFeature`, `bugFix`, `updatedDocs` or `enhancement`. This is used for automatic release notes creation.
- Make sure that the issue is tagged in the PR.
- Write a short but informative commit message, it will be added to the release notes.

## Feature Suggestions

- Please first search [Open Issues](https://github.com/PSBicep/PSBicep/issues) before opening an issue to check whether your feature has already been suggested. If it has, feel free to add your own comments to the existing issue.
- Ensure you have included a "What?" - what your feature entails, being as specific as possible, and giving mocked-up syntax examples where possible.
- Ensure you have included a "Why?" - what the benefit of including this feature will be.
- Use the "Feature Request" issue template [here](https://github.com/PSBicep/PSBicep/issues/new/choose) to submit your request.

## Bug Reports

- Please first search [Open Issues](https://github.com/PSBicep/PSBicep/issues) before opening an issue, to see if it has already been reported.
- Try to be as specific as possible, including the version of the Bicep PowerShell module, PowerShell version and OS used to reproduce the issue, and any example files or snippets of Bicep code needed to reproduce it.
- Use the "Bug Report" issue template [here](https://github.com/PSBicep/PSBicep/issues/new/choose) to submit your request.
