# Changelog for Bicep

The format is based on and uses the types of changes according to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- New cmdlets: `Get-BicepResourceProvider`, `Get-BicepResourceType`, and `Get-BicepChildResourceType` for enhanced resource type retrieval.
- C# base argument completions in `BicepTypesCompleters`
- Custom `StringComparer` that lets us sort resource types with `ApiVersion` alphabetically while still keeping the latest API version on top.
- New parameters on `New-BicepMarkdownDocumentation`: `-OutputPath`, `-OutputDirectory`, `-TemplateFile`, `-TemplateRoot`, `-CustomValue`, `-CustomValueFilePath` and `-NoRestore`, mirroring the switches of the new `bicep docs generate` CLI command. `-Force` is now honored: an existing output file is no longer overwritten without it.
- `New-BicepMarkdownDocumentation` supports `-WhatIf` and `-Confirm`.

### Changed

- Use Bicep version 0.47.16
- `Get-BicepConfig` default configuration now includes the `documentation` section and `experimentalFeaturesWarning`, matching Bicep's built-in defaults
- Internal: the cloned configuration manager was rewritten as `PSBicepConfigurationManager` on top of Bicep's new configuration chain API (`bicepconfig.json` `extends` support)
- **Breaking** `New-BicepMarkdownDocumentation` now uses Bicep's native documentation generator (the engine behind `bicep docs generate`) instead of hand-rolled markdown tables. The output format changed entirely and the default output file name is now `README.md` (configurable via `documentation.output.file` in `bicepconfig.json`) instead of `<name>.md`.
- **Breaking** `New-BicepMarkdownDocumentation` now takes a single `-Path` parameter that accepts either a bicep file or a folder, replacing the separate `-File` and `-Path` parameters. `-Path` accepts several paths, supports wildcards, takes file and folder paths from the pipeline (so `Get-ChildItem *.bicep | New-BicepMarkdownDocumentation` works) and defaults to the current directory, matching `Build-Bicep` and `Format-BicepFile`. A folder or a wildcard expands to the `*.bicep` files it matches, while a path naming a single file is used as given.
- **Breaking** `-AsString`, `-OutputPath` and `-OutputDirectory` on `New-BicepMarkdownDocumentation` are now mutually exclusive parameter sets instead of runtime errors, so invalid combinations fail at parameter binding.
- Migrate help generation from legacy PlatyPS to Microsoft.PowerShell.PlatyPS module
- `Get-BicepApiVersion`: Improved argument completion and output handling
- Update Sampler files to match upstream Sampler
- Update GitHub Actions dependencies to latest version

### Removed

- Dependency on `BicepTypes.json` in favor of native type resolution
- Dynamic update of `BicepTypes.json` and related tests are no longer supported
- Private markdown helper functions `NewMDMetadata`, `NewMDProviders`, `NewMDResources`, `NewMDParameters`, `NewMDVariables`, `NewMDOutputs`, `NewMDModules` and `NewMDTableHeader`, replaced by the native Bicep documentation generator
- **Breaking** The `-File` parameter of `New-BicepMarkdownDocumentation`, replaced by `-Path`

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
