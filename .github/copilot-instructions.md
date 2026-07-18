# Copilot Instructions for PSBicep

This document provides context and guidance for working with the Bicep PowerShell Module repository.

## Build, Test, and Lint

### Building the Module
The module is built using a custom PowerShell build script.
- **Full Build (including dependency resolution):**
  ```powershell
  .\build.ps1 -ResolveDependency -Task build
  ```
- **Build without dependency resolution:**
  ```powershell
  .\build.ps1 -Task build
  ```
The built module is placed in the `output/Bicep` directory.

### Running Tests
Tests are implemented using the [Pester](https://github.com/pester/Pester) framework.
- **Run all tests:**
  ```powershell
  .\build.ps1 -Tasks test
  ```
- **Run a specific test file:**
  You can run Pester tests directly on a file:
  ```powershell
  Invoke-Pester -Path .\Tests\Build-Bicep.Tests.ps1
  ```

## High-Level Architecture

The repository consists of three main components:

1.  **PSBicep.Core (C#):** A thin C# wrapper around the Bicep CLI. It handles the loading of Bicep assemblies and provides the core functionality.
2.  **PSBicep (PowerShell Module Wrapper):** A PowerShell module that loads the `PSBicep.Core` assemblies into a separate Assembly Load Context to prevent version conflicts with other modules.
3.  **Source (PowerShell Implementation):** The main source code for the PowerShell module, containing the public and private functions exposed to users.

### Directory Structure
- `PSBicep.Core/`: C# project for Bicep assembly wrapping.
- `PSBicep/`: PowerShell module wrapper logic.
- `Source/`: Main PowerShell module source code.
    - `Public/`: Exported PowerShell functions.
    - `Private/`: Internal helper functions.
    - `Classes/`: Custom PowerShell classes.
    - `en-US/`: Generated help files (via Microsoft.PowerShell.PlatyPS).
- `Tests/`: Pester test suites.
- `Docs/Bicep/`: Markdown source files for command help documentation.

## Key Conventions

### Documentation and Help
- **Microsoft.PowerShell.PlatyPS:** External help is generated from Markdown files located in `Docs/Bicep/` using [Microsoft.PowerShell.PlatyPS](https://github.com/PowerShell/platyPS). 
- When adding or updating commands, ensure the corresponding Markdown file in `Docs/Bicep/` is updated and contains any necessary placeholders (e.g., `{{ ... }}`).

### Module Structure
- **Public vs. Private:** All functions intended for end-users must be placed in `Source/Public/`. Internal implementation details should reside in `Source/Private/`.
- **Assembly Loading:** The module uses a custom Assembly Load Context to manage Bicep assemblies, ensuring isolation and stability.

### Testing
- **Pester:** All tests follow Pester conventions. Tests are located in the `Tests/` directory and typically mirror the structure of the source code.
