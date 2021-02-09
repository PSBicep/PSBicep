# Build-Bicep

`Build-Bicep` is equivalent to `bicep build` but with some extra features.

- Compile all files in a folder
- Generate ARM Template Parameter files

```powershell
Build-Bicep
    [-Path <string>]
    [-OutputDirectory <string>]
    [-ExcludeFile <String>]
    [-GenerateParameterFile]
    [-AsString]
```

>NOTE: In previous versions of the module the `Invoke-BicepBuild` was used to compile bicep files. Since version `1.3.0` we have changed it to `Build-Bicep` instead but `Invoke-BicepBuild` remains as an alias.

## Parameters

**`-Path`**
Specifies the path to the `.bicep` file(s) to compile.

**`-OutputDirectory`**
Specifies the path where the compiled ARM Template `.json` file(s) should be outputted.

**`-ExcludeFile`**
Specifies files to exclude from compilation. Enter a full path or file name.

**`-GenerateParameterFile`**
Use this switch to generate ARM Template parameter files for the `.bicep` file(s) compiled. The ARM Template parameter file will be named `<filename>.parameters.json`.

**`-AsString`**
Prints all output as a string instead of corresponding files.

## Examples

### 1. Compile single bicep file in working directory

```powershell
Build-Bicep -Path vnet.bicep
```

### 2. Compile single bicep file in different directory

```powershell
Build-Bicep -Path 'c:\bicep\modules\vnet.bicep'
```

### 3. Compile all .bicep files in working directory

```powershell
Build-Bicep
```

### 4. Compile all .bicep files and specify output folder

```powershell
Build-Bicep -Path 'c:\bicep\modules\' OutputDirectory 'c:\ARMTemplates\'
```

### 5. Compile all .bicep files in working directory except firewall.bicep

```powershell
Build-Bicep -Path 'c:\bicep\modules\' -ExcludeFile firewall.bicep
```

### 6. Compile all .bicep files in working directory and generate ARM Template parameter files

```powershell
Build-Bicep -Path 'c:\bicep\modules\' -GenerateParameterFile
```

### 7. Compile single bicep file in working directory and output as a string

```powershell
Build-Bicep -Path vnet.bicep -AsString
```
