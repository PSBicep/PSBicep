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
        
        # Try to find a matching Bicep template for the provided parameter file based on its file name
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
        
        # Import the old parameter file and convert it to an ordered hashtable
        $oldParametersFile = Get-Content -Path $Path | ConvertFrom-Json -Depth 100 | ConvertToHashtable -Ordered

        # Generate a temporary Bicep Parameter File with all parameters
        $BicepFileName = (Get-Item -Path $BicepFilePath).BaseName
        New-BicepParameterFile -Path $BicepFilePath -OutputDirectory $tempPath -Parameters All

        $allParametersFilePath = $tempPath + "$($BicepFileName).parameters.json"

        # Convert the all parameters file to an ordered hashtable
        try {
            $allParametersFile = Get-Content -Path $allParametersFilePath -ErrorAction Stop | ConvertFrom-Json -Depth 100 | ConvertToHashtable -Ordered
        }
        catch {
            Write-Error "Failed to create Bicep ParameterObject."
            Break
        }        

        # Remove any deleted parameters from old parameter file
        $oldParameterArray = @()
        $oldParametersFile.parameters.Keys.ForEach( { $oldParameterArray += $_ })
        
        foreach ($item in $oldParameterArray) {
            if (-not $allParametersFile.parameters.Contains($item)) {
                $oldParametersFile.parameters.Remove($item)
            }
        }
        
        
        # Generate a new temporary Bicep Parameter File if -Parameters parameter is set to Required
        if ($Parameters -eq 'Required') {
            $BicepFileName = (Get-Item -Path $BicepFilePath).BaseName
            New-BicepParameterFile -Path $BicepFilePath -OutputDirectory $tempPath -Parameters $Parameters
        }
        $NewParametersFilePath = $tempPath + "$BicepFileName.parameters.json"
        
        # Convert the new parameter file to an ordered hashtable
        try {
            $NewParametersFile = Get-Content -Path $NewParametersFilePath -ErrorAction Stop | ConvertFrom-Json -Depth 100 | ConvertToHashtable -Ordered
        }
        catch {
            Write-Error "Failed to create Bicep ParameterObject."
            Break
        }
        
        $ParameterArray = @()
        $NewParametersFile.parameters.Keys.ForEach( { $ParameterArray += $_ })
        
        # Iterate over the new parameters and add any missing to the old parameters array
        foreach ($item in $ParameterArray) {
            if (-not $oldParametersFile.parameters.Contains($item)) {
                $oldParametersFile.parameters[$item] = @{                                
                    value = $NewParametersFile.parameters.$item.value
                }
            }
        }
        $oldParametersFile | ConvertTo-Json -Depth 100 | Out-File -Path $Path -Force
        
    }
    end {
        Remove-Item $NewParametersFilePath -Force
    }
}