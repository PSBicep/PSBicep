class BicepRestoreParametersRelativePath : BicepRestoreParametersBase {
    
    BicepRestoreParametersRelativePath([object]$Object) {
        BicepRestoreParametersRelativePath($Object, $PWD.Path)
    }

    BicepRestoreParametersRelativePath([string]$Fullname) {
        $RelativePath = Resolve-Path -Path $Fullname -Relative -ErrorAction 'Stop'
        $SplitPath = $RelativePath.Split([System.IO.Path]::DirectorySeparatorChar)
        $FileNamePattern = '^(.+)-(\d+)\.bicep$'
        $This.Name = $SplitPath[-1] -replace $FileNamePattern, '$1'
        $This.Version = '{0}-{1}' -f $SplitPath[-2], ($SplitPath[-1] -replace $FileNamePattern, '$2')
        $This.Type = 'RelativePath'
        $This.Source = $SplitPath[ - $SplitPath.Length..-3] -join '/'
    }
    
    BicepRestoreParametersRelativePath([object]$Object, [string]$BasePath) {
        if ($Object.Version -notmatch '^\d\d\d\d-\d\d-\d\d-\d$') {
            throw ('{0} is not a valid version.' -f $Object.Version)
        }
        Push-Location -Path $BasePath -ErrorAction 'Stop'
        $this.Type = $Object.Type 
        $this.Version = $Object.Version 
        $this.Name = $Object.Name 
        $this.Source = Resolve-Path -Path $Object.Source -ErrorAction 'Stop'
        $this.BasePath = $BasePath
        Pop-Location -ErrorAction 'Stop'
    }

    [void] Restore($Path) {
        $DestinationPath = $this.ResolveDestinationPath($Path)
        
        $ApiVersion = $this.Version -replace '-\d+$'
        $ModuleVersion = $this.Version -replace '.+-(\d+)$', '$1'
        $SourceFileName = '{0}-{1}.bicep' -f $this.Name, $ModuleVersion
        $SourcePath = Join-Path -Path $this.Source -ChildPath $APIVersion -AdditionalChildPath $SourceFileName
        
        if (-not (Test-Path -Path $SourcePath -PathType 'Leaf')) {
            throw "File not found: $SourcePath"
        }

        Write-Verbose -Message "Restoring to path: $SourcePath to $DestinationPath"
        $null = Copy-Item -Path $SourcePath -Destination $DestinationPath -ErrorAction 'Stop'
    }
}