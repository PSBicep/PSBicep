# Bicep PowerShell - Bicep version comparison

When Bicep PowerShell `v1.3.0` was released the official [Bicep](https://github.com/Azure/bicep) assemblies were shipped with the module and loaded during module import instead of wrapping the Bicep CLI. And with the release of Bicep PowerShell `v2.0.0` the module is using the nested module [BicepNet](https://github.com/PSBicep/BicepNet) instead to create a separate load context to avoid conflicts with other modules.

The table below shows which version of the Bicep assemblies and BicepNet that are used for each version of the module.

| Bicep PowerShell version | Bicep assembly version | BicepNet Version |
| --- | --- | -- |
| `2.3.0` | `0.7.4` | `2.0.6` |
| `2.2.0` | `0.6.18` | `2.0.4` |
| `2.1.0` | `0.4.1008` | `1.0.7` |
| `2.0.0` | `0.4.451` | `1.0.4` |
| `2.0.0-Preview2` | `0.4.451` | `1.0.4` |
| `2.0.0-Preview1` | `0.4.63` | `1.0.2` |
| `1.5.1` | `0.4.63` | `N/A` |
| `1.5.0` | `0.4.63` | `N/A` |
| `1.4.7` | `0.3.539` | `N/A` |
| `1.4.6` | `0.3.255` | `N/A` |
| `1.4.5` | `0.3.255` | `N/A` |
| `1.4.4` | `0.3.255` | `N/A` |
| `1.4.3` | `0.3.126` | `N/A` |
| `1.4.2` | `0.3.1` | `N/A` |
| `1.4.1` | `0.3.1` | `N/A` |
| `1.4.0` | `0.3.1` | `N/A` |
| `1.3.0` | `0.2.328` | `N/A` |
