function Update-BicepParameterFile {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('\.json$', ErrorMessage = 'Path must be a parameters file with a .json extension.')]
        [Parameter(Mandatory, Position = 1)]
        [string]$Path,

        [ValidateNotNullOrEmpty()]
        [ValidatePattern('\.bicep$', ErrorMessage = 'BicepFile must have a .bicep extension.')]
        [Parameter(Position = 2)]
        [string]$BicepFile,

        [ValidateNotNullOrEmpty()]
        [Parameter(Position = 3)]
        [ValidateSet('All', 'Required')]
        [string]$Parameters = 'All'
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
        
        if (-not $PSBoundParameters.ContainsKey('BicepFile')) {
            $BicepFilePath = (Get-ChildItem $ParamFile.DirectoryName -Filter *.bicep | Where-Object { $_.BaseName -eq $FileName }).FullName

            if (-not $BicepFilePath) {
                Write-Error "Cant find BicepFile Named $FileName in directory: $($ParamFile.DirectoryName)"
                Break
            }
        }
        else {
            if (-not (Test-Path $BicepFile)) {
                Write-Error "Cant find BicepFile at specified Path $BicepFile."
                Break
            }
            $BicepFilePath = $BicepFile
        }

        $BicepFileName = (Get-Item -Path $BicepFilePath).BaseName
        New-BicepParameterFile -Path $BicepFilePath -OutputDirectory $tempPath -Parameters $Parameters

        $NewParametersFilePath = $tempPath+"$BicepFileName.parameters.json"

        try {
            $NewParametersFile = Get-Content -Path $NewParametersFilePath -ErrorAction Stop | ConvertFrom-Json -Depth 100 | ConvertToHashtable -Ordered
        }
        catch {
            Write-Error "Failed to create Bicep ParameterObject."
            Break
        }
        
        $OldParametersFile = Get-Content -Path $Path | ConvertFrom-Json -Depth 100 | ConvertToHashtable -Ordered

        $ParameterArray = @()
        $NewParametersFile.parameters.Keys.ForEach({ $ParameterArray += $PSItem })
        
        foreach ($item in $ParameterArray) {
            if ($OldParametersFile.parameters.Contains($item)) {
                $NewParametersFile.parameters[$item] = $OldParametersFile.parameters[$item]
            }
        }
        $NewParametersFile | ConvertTo-Json -Depth 100 | Out-File -Path $Path -Force
        
    }
    end {
        Remove-Item $NewParametersFilePath -Force
    }
}
