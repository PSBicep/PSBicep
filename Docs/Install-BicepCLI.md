# Install-BicepCLI

`Install-BicepCLI` is a command to install the latest Bicep CLI release available from the Azure/Bicep repo.

```powershell
Install-BicepCLI
    [-Force]
```

## Parameters

**`-Force`**
Installs Bicep CLI and overrides warning messages about module installation conflicts.

## Examples

### 1. Install Bicep CLI

```powershell
Install-BicepCLI
```

### 2. Install Bicep CLI using force

```powershell
Install-BicepCLI -Force
```
