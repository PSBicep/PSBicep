# Bicep - PowerShell Module
This is the repo for the Bicep PowerShell Module. The module is created as a wrapper for the [Bicep CLI](https://github.com/Azure/bicep). It started with a simple function to enable compilation of all bicep files in a folder, but I came up with additional use cases and the Bicep Module was born.

Commands implemented:
- Invoke-BicepBuild
- ConvertTo-Bicep
- Get-BicepVersion
- Install-BicepCLI
- Update-BicepCLI
- Uninstall-BicepCLI

## Installation

Bicep PowerShell Module is published to [PowerShell Gallery](https://www.powershellgallery.com/packages/Bicep/1.1.0).

```powershell
Install-Module -Name Bicep
```
 
>**Note:** The cmdlets `Invoke-BicepBuild`, `ConvertTo-Bicep` and `Get-BicepVersion` all requires Bicep CLI to be installed on your device. After intalling the Bicep PowerShell Module you can install the latest release of Bicep CLI using the cmdlet `Install-BicepCLI`. In future versions I plan to remove that requirement and replace it with `Bicep Core`.

## Cmdlets

### Invoke-BicepBuild

`Invoke-BicepBuild` is equivalent to `bicep build` but with some extra features.

- Compile all files in a folder
- Generate ARM Template Parameter files

```powershell
Invoke-BicepBuild
    [-Path <string>]
    [-ExcludeFile <String>]
    [-GenerateParameterFile]
```

#### Parameters

**`-Path`**
Specifies the path to the `.bicep` file(s) to compile.

**`-ExcludeFile`**
Specifies files to exclude from compilation. Enter a full path or file name.

**`-GenerateParameterFile`**
Use this switch to generate ARM Template parameter files for the `.bicep` file(s) compiled. The ARM Template parameter file will be named `<filename>.parameters.json`.

#### Examples

##### 1. Compile single bicep file in working directory

```powershell
Invoke-BicepBuild vnet.bicep
```

##### 2. Compile single bicep file in different directory

```powershell
Invoke-BicepBuild 'c:\bicep\modules\vnet.bicep'
```

##### 3. Compile all .bicep files in working directory

```powershell
Invoke-BicepBuild
```

##### 4. Compile all .bicep files in different directory

```powershell
Invoke-BicepBuild -Path 'c:\bicep\modules\'
```

Or:

```powershell
Invoke-BicepBuild 'c:\bicep\modules\'
```

##### 5. Compile all .bicep files in working directory except firewall.bicep

```powershell
Invoke-BicepBuild -Path 'c:\bicep\modules\' -ExcludeFile firewall.bicep
```

##### 6. Compile all .bicep files in working directory and generate ARM Template parameter files

```powershell
Invoke-BicepBuild -Path 'c:\bicep\modules\' -GenerateParameterFile
```

### ConvertTo-Bicep

`ConvertTo-Bicep` is equivalent to `bicep decompile` but with the possibility to decompile all `.bicep` files in a directory.

```powershell
ConvertTo-Bicep
    [-Path <string>]
```

#### Parameters

**`-Path`**
Specifies the path to the `.bicep` file(s) to decompile.

#### Examples

##### 1. Decompile single .json file in working directory

```powershell
ConvertTo-Bicep vnet.json
```

##### 2. Decompile single .json file in different directory

```powershell
ConvertTo-Bicep 'c:\armtemplates\vnet.json'
```

##### 3. Decompile all .json files in working directory

```powershell
ConvertTo-Bicep
```

##### 4. Decompile all .json files in different directory

```powershell
ConvertTo-Bicep -Path 'c:\armtemplates\'
```

Or:

```powershell
Invoke-BicepBuild 'c:\armtemplates\'
```

#### Get-BicepVersion

`Get-BicepVersion` is a command to compare the installed version of Bicep CLI with the latest release available in the Azure/Bicep repo.

```powershell
Get-BicepVersion
```

#### Examples

##### 1. Compare installed version with latest release

```powershell
Get-BicepVersion

InstalledVersion LatestVersion
---------------- -------------
0.2.212          0.2.212
```

### Install-BicepCLI

`Install-BicepCLI` is a command to install the latest Bicep CLI release available from the Azure/Bicep repo.

```powershell
Install-BicepCLI
    [-Force]
```

#### Parameters

**`-Force`**
Installs Bicep CLI and overrides warning messages about module installation conflicts.

#### Examples

##### 1. Install Bicep CLI

```powershell
Install-BicepCLI
```

##### 2. Install Bicep CLI using force

```powershell
Install-BicepCLI -Force
```

### Update-BicepCLI

`Update-BicepCLI` is a command to update Bicep CLI to the latest realease available from the Azure/Bicep repo.

```powershell
Update-BicepCLI
```

#### Examples

##### 1. Update Bicep CLI

```powershell
Update-BicepCLI
```
### Uninstall-BicepCLI

`Uninstall-BicepCLI` is a command to remove Bicep CLI from a device.

```powershell
Uninstall-BicepCLI
    [-Force]
```

#### Parameters

**`-Force`**
Tries to uninstall Bicep CLI even if the PowerShell session isn't elevated.

#### Examples

##### 1. Uninstall Bicep CLI from a non-elevated PowerShell Session

```powershell
Uninstall-BicepCLI -Force
```

##### 2. Uninstall Bicep CLI from an elevated PowerShell Session

```powershell
Uninstall-BicepCLI
```

## Bug report and feature requests

If you find a bug or have an idea for a new feature create an issue in the repo. This is also the place where you can see any planned features.

## Contribution

If you like the Bicep PowerShell module and want to contribute you are very much welcome to do so. Please create an issue before you start working with a brand new feature to make sure that it’s not already in the works or that the idea has been dismissed already.
