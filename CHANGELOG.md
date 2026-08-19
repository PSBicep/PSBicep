# Changelog for Bicep

The format is based on and uses the types of changes according to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- New cmdlets: `Get-BicepResourceProvider`, `Get-BicepResourceType`, and `Get-BicepChildResourceType` for enhanced resource type retrieval.
- C# base argument completions in `BicepTypesCompleters`
- Custom `StringComparer` that lets us sort resource types with `ApiVersion` alphabetically while still keeping the latest API version on top.
- New parameters on `New-BicepMarkdownDocumentation`: `-OutputPath`, `-OutputDirectory`, `-TemplateFile`, `-TemplateRoot`, `-CustomValue`, `-CustomValueFilePath` and `-NoRestore`, mirroring the switches of the new `bicep docs generate` CLI command. `-Force` is now honored: an existing output file is no longer overwritten without it.

### Changed

- Use Bicep version 0.47.x
- **Breaking** `New-BicepMarkdownDocumentation` now uses Bicep's native documentation generator (the engine behind `bicep docs generate`) instead of hand-rolled markdown tables. The output format changed entirely and the default output file name is now `README.md` (configurable via `documentation.output.file` in `bicepconfig.json`) instead of `<name>.md`.
- Migrate help generation from legacy PlatyPS to Microsoft.PowerShell.PlatyPS module
- `Get-BicepApiVersion`: Improved argument completion and output handling
- Update Sampler files to match upstream Sampler
- Update GitHub Actions dependencies to latest version

### Removed

- Dependency on `BicepTypes.json` in favor of native type resolution
- Dynamic update of `BicepTypes.json` and related tests are no longer supported
- Private markdown helper functions `NewMDMetadata`, `NewMDProviders`, `NewMDResources`, `NewMDParameters`, `NewMDVariables`, `NewMDOutputs`, `NewMDModules` and `NewMDTableHeader`, replaced by the native Bicep documentation generator

## [3.0.0] - 2026-04-09

### Changed
- **Breaking** Requires minimum version of PowerShell 7.6 due to .NET 10 requirements of Bicep
- Bicep support for version 0.41.2

### Fixed
- Fix bug in Export-BicepResource logged in issue [#373](https://github.com/PSBicep/PSBicep/issues/373)
- Improved Export-BicepResource to not throw an error when failing to export a single resource

## [2.9.2] - 2025-07-09

### Removed
- Unused private functions WriteErrorStream, GetAzResourceGraphPage and Search-AzureResourceGraph

### Changed

- Take dependency on AzResourceGraph module
- Fix bug with Get-BicepConfig not properly resolving paths

### Added

- Bicep support for version 0.30.23
- Clear-BicepModuleCache has new parameter -Path to support custom cache path set in bicepconfig (fixes #306)
- Publish-Bicep now supports -DocumentationUri (fixes #294)
