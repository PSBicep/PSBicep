Function Get-UsedModulesInBicepFile {
    param(
        [cmdletbinding()]
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    try {
        $BicepFile = Get-Content -Path $Path -Raw | Out-String
    }
    catch {
        throw "Could not read file $Path"
    }

    $UsedModules = @()

    [regex]::matches($BicepFile, "^\s*module\s+(\w+)\s+'([^']+)'", "Multiline") | ForEach-Object {
        $_ | ForEach-Object {
            $ModuleName = $_.Groups[1].value
            $ModulePath = $_.Groups[2].Value

            $UsedModules += [PSCustomObject]@{
                Name = $ModuleName
                Path = $ModulePath
            }
        }
    }

    if ($UsedModules.Count -eq 0) {
        Write-Verbose -Verbose "No modules were found in the Bicep file."
    }

    # Make sure it returns an array of objects
    
    return ,$UsedModules

}