# BicepPowerShell
This is the repo for the Bicep PowerShell Module.

Commands implemented:
- Invoke-BicepBuild
- ConvertFrom-Bicep
- Get-BicepVersion
- Install-BicepCLI
- Update-BicepCLI

## Instructions

### Invoke-BicepBuild
`Invoke-BicepBuild` is equivalent to `bicep build` but with the possibility to compile all `.bicep` files in a directory.

#### Examples

#### 1. Compile single bicep file in working directory
`Invoke-BicepBuild vnet.bicep`

#### 2. Compile single bicep file in different directory
`Invoke-BicepBuild 'c:\bicep\modules\vnet.bicep'`

#### 3. Compile all .bicep files in working directory
`Invoke-BicepBuild`

#### 4. Compile all .bicep files in different directory
`Invoke-BicepBuild -Path 'c:\bicep\modules\'`

Or

`Invoke-BicepBuild 'c:\bicep\modules\'`


