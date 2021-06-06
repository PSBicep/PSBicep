function Update-BicepParameterFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 1)]
        [string]$Path,

        [Parameter(Position = 2)]
        [string]$BicepFile
    )

    begin {

        $tempPath = [System.Io.Path]::GetTempPath()

    }
    process {
        
        try {
            $ParamFile = Get-Item -Path $Path -ErrorAction Stop
        }
        catch {
            Write-Error "Cant find ParameterFile at specified Path $Path."
            Break
        }
        
        $FileName = $ParamFile.BaseName.Replace('.parameters', '')
        
        if (!$BicepFile) {
            $BicepFilePath = (Get-Item * | Where-Object { $_.Name -like "$FileName.bicep" }).FullName
            if (!$BicepFilePath) {
                Write-Error "Cant find BicepFile Named $FileName in current Directory."
                Break
            }
        }
        else {
            if (!(Test-Path $BicepFile)) {
                Write-Error "Cant find BicepFile at specified Path $BicepFile."
                Break
            }
            $BicepFilePath = $BicepFile
        }
        
        $BicepFileName = (Get-Item -Path $BicepFilePath).BaseName.Replace('.bicep', '')
        New-BicepParameterFile -Path $BicepFilePath -OutputDirectory $tempPath -Parameters All 

        $NewParametersFilePath = "$tempPath\$BicepFileName.parameters.json"
        
        try {
            $NewParametersFile = Get-Content -Path $NewParametersFilePath -ErrorAction Stop | ConvertFrom-Json -Depth 100 | ConvertToHashtable -Ordered
        }
        catch {
            Write-Error "Failed to create Bicep ParameterObject."
            Break
        }
        
        $OldParametersFile = Get-Content -Path $Path | ConvertFrom-Json -Depth 100 | ConvertToHashtable -Ordered
        $UpdatedParametersFile = $NewParametersFile

        foreach ($Obj in $($NewParametersFile.parameters.Keys)) {
            foreach ($Param in $($OldParametersFile.parameters.Keys)) {
                if ($Obj -eq $Param) {
                    $UpdatedParametersFile.parameters[$Obj] = $OldParametersFile.parameters[$Obj]
                }
            }
        }
        
        $UpdatedParametersFile | ConvertTo-Json -Depth 100 | Out-File -Path $Path -Force
        
    }
    end {
        Remove-Item $NewParametersFilePath -Force
    }
}