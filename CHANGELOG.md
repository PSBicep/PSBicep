# Changelog for Bicep

The format is based on and uses the types of changes according to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Fix bug with Get-BicepConfig not properly resolving paths

### Added

- Bicep support for version 0.30.23
- Clear-BicepModuleCache has new parameter -Path to support custom cache path set in bicepconfig (fixes #306)
- Publish-Bicep now supports -DocumentationUri (fixes #294)
