Function Get-UsedModulesInBicepFile {
    param(
        [cmdletbinding()]
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    try {
        $BicepFile = Get-Content -Path $Path -Raw
    }
    catch {
        throw "Could not read file $Path"
    }

    $UsedModules = @()


    $BicepFile | Select-String -Pattern "module\s+(\w+)\s+'([^']+)'" -AllMatches | ForEach-Object {
        $_.Matches | ForEach-Object {
            $ModuleName = $_.Groups[1].Value
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