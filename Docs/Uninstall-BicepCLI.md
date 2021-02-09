# Uninstall-BicepCLI

`Uninstall-BicepCLI` is a command to remove Bicep CLI from a device. The command will uninstall Bicep CLI installed using both Windows Installer and PowerShell install script provided in the Bicep repo.

```powershell
Uninstall-BicepCLI
    [-Force]
```

## Parameters

**`-Force`**
Tries to uninstall Bicep CLI even if the PowerShell session isn't elevated.

## Examples

### 1. Uninstall Bicep CLI from a non-elevated PowerShell Session

```powershell
Uninstall-BicepCLI -Force
```

### 2. Uninstall Bicep CLI from an elevated PowerShell Session

```powershell
Uninstall-BicepCLI
```
