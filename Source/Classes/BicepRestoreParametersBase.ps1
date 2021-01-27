class BicepRestoreParametersBase {
    # Hack to create an abstract-like class
    [string] $Name

    [string] $Version

    [string] $Type

    [string] $Source

    [string] $BasePath

    BicepRestoreParametersBase() {
        if ($this.GetType() -eq [BicepRestoreParametersBase]) {
            throw('Class BicepRestoreParametersBase must be inherited')
        }
    }

    [void] Restore($Path) {
        throw('Restore method not implemented in type {0}' -f $this.GetType().FullName)
    }

    [string] ResolveDestinationPath($Path) {
        Push-Location -Path $this.BasePath
        if (Test-Path -Path $Path -PathType 'Leaf') {
            throw 'Invalid path, needs to be a directory.'
        }
        if (-not (Test-Path -Path $Path)) {
            $null = New-Item -ItemType Directory -Path $Path
        }
        $DestinationFolder = Resolve-Path -Path $Path -ErrorAction 'Stop' | Select-Object -ExpandProperty Path
        $DestinationFileName = '{0}.bicep' -f $this.Name
        $DestinationPath = Join-Path -Path $DestinationFolder -ChildPath $DestinationFileName
        return $DestinationPath
    }

    [System.Collections.Specialized.OrderedDictionary] ToOrderedHashTable() {
        return [ordered]@{
            Name = $this.Name
            Version = $this.Version
            Type = $this.Type
            Source = $this.Source
            BasePath = $this.BasePath
        }
    }
}