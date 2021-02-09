# ConvertTo-Bicep

`ConvertTo-Bicep` is equivalent to `bicep decompile` but with some extra features.

- Decompile all `.bicep` files in a directory
- Output ARM Template directly as string without writing to file

```powershell
ConvertTo-Bicep
    [-Path <string>]
    [-OutputDirectory  <string>]
    [-AsString]
```

## Parameters

**`-Path`**
Specifies the path to the ARM Template`.json` file(s) to decompile.

**`-OutputDirectory`**
Specifies the path where the decompiled `.bicep` file(s) should be outputted.

**`-AsString`**
Prints all output as a string instead of corresponding files.

## Examples

### 1. Decompile single .json file in working directory

```powershell
ConvertTo-Bicep -Path vnet.json
```

### 2. Decompile single .json file in different directory

```powershell
ConvertTo-Bicep -Path 'c:\armtemplates\vnet.json'
```

### 3. Decompile single .json file and specify output directory

```powershell
ConvertTo-Bicep -Path vnet.json -OutputDirectory 'c:\bicep\'
```

### 4. Decompile all .json files in different directory

```powershell
ConvertTo-Bicep -Path 'c:\armtemplates\'
```

### 6. Decompile single .json file output as string

```powershell
ConvertTo-Bicep -Path vnet.json -AsString
```
