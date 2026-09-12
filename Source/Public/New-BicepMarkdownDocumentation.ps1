function New-BicepMarkdownDocumentation {
    [CmdletBinding(DefaultParameterSetName = 'FromFile')]
    param (
        [Parameter(ParameterSetName = 'FromFile', Position = 0, Mandatory)]
        [string]$File,

        [Parameter(ParameterSetName = 'FromFolder', Position = 0, Mandatory)]
        [string]$Path,

        [Parameter(ParameterSetName = 'FromFolder')]
        [switch]$Recurse,

        [Parameter(ParameterSetName = 'FromFile')]
        [string]$OutputPath,

        [Parameter(ParameterSetName = 'FromFile')]
        [Parameter(ParameterSetName = 'FromFolder')]
        [string]$OutputDirectory,

        [Parameter(ParameterSetName = 'FromFile')]
        [Parameter(ParameterSetName = 'FromFolder')]
        [string]$TemplateFile,

        [Parameter(ParameterSetName = 'FromFile')]
        [Parameter(ParameterSetName = 'FromFolder')]
        [string]$TemplateRoot,

        [Parameter(ParameterSetName = 'FromFile')]
        [Parameter(ParameterSetName = 'FromFolder')]
        [hashtable]$CustomValue,

        [Parameter(ParameterSetName = 'FromFile')]
        [Parameter(ParameterSetName = 'FromFolder')]
        [string[]]$CustomValueFilePath,

        [Parameter(ParameterSetName = 'FromFile')]
        [Parameter(ParameterSetName = 'FromFolder')]
        [switch]$NoRestore,

        [Parameter(ParameterSetName = 'FromFile')]
        [Parameter(ParameterSetName = 'FromFolder')]
        [switch]$AsString,

        [Parameter(ParameterSetName = 'FromFile')]
        [Parameter(ParameterSetName = 'FromFolder')]
        [switch]$Force
    )

    if ($OutputPath -and $OutputDirectory) {
         throw 'The -OutputPath and -OutputDirectory parameters cannot be combined.'
    }

    if ($AsString.IsPresent -and ($OutputPath -or $OutputDirectory -or $Force.IsPresent)) {
        throw 'The -AsString parameter cannot be combined with -OutputPath, -OutputDirectory or -Force.'
    }

    switch ($PSCmdLet.ParameterSetName) {
        'FromFile' {
            [System.IO.FileInfo[]]$FileCollection = Get-Item $File
        }
        'FromFolder' {
            [System.IO.FileInfo[]]$FileCollection = Get-ChildItem $Path *.bicep -Recurse:$Recurse
        }
    }

    Write-Verbose "Files to process:`n$($FileCollection.Name)"

    #region Merge custom template values
    $MergedCustomValues = @{}
    foreach ($ValueFile in $CustomValueFilePath) {
        try {
            $ValueFileContent = Get-Content -Path $ValueFile -Raw -ErrorAction Stop | ConvertFrom-Json -AsHashtable -ErrorAction Stop
        }
        catch {
            throw "Failed to read custom template values from '$ValueFile' - $($_.Exception.Message)"
        }

        if ($ValueFileContent -isnot [hashtable]) {
            throw "The custom template value file '$ValueFile' must contain a JSON object."
        }

        foreach ($Key in $ValueFileContent.Keys) {
            $Value = $ValueFileContent[$Key]
            if ($Value -is [System.Collections.IDictionary] -or $Value -is [array]) {
                throw "The custom template value '$Key' in '$ValueFile' must be a string, number or boolean."
            }
            $MergedCustomValues[$Key] = [string]$Value
        }
    }
    foreach ($Key in ($CustomValue ?? @{}).Keys) {
        $MergedCustomValues[$Key] = [string]$CustomValue[$Key]
    }
    if ($MergedCustomValues.Count -eq 0) {
        $MergedCustomValues = $null
    }
    #endregion

    $DocumentationParameters = @{}
    if ($TemplateFile) { $DocumentationParameters['TemplateFile'] = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($TemplateFile) }
    if ($TemplateRoot) { $DocumentationParameters['TemplateRoot'] = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($TemplateRoot) }
    if ($MergedCustomValues) { $DocumentationParameters['CustomValue'] = $MergedCustomValues }

    if ($PSCmdLet.ParameterSetName -eq 'FromFolder') {
        $SourceRoot = (Resolve-Path -Path $Path).ProviderPath
    }

    $EmittedTargets = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)

    foreach ($SourceFile in $FileCollection) {
        #region Generate documentation using the native Bicep documentation generator
        try {
            $Documentation = New-BicepDocumentation -Path $SourceFile.FullName -NoRestore:$NoRestore @DocumentationParameters -ErrorAction Stop
        }
        catch {
            Write-Error -Message "Failed to generate documentation for $($SourceFile.Name) - $($_.Exception.Message)"

            switch ($ErrorActionPreference) {
                'Stop' { throw }
                default { continue }
            }
        }
        #endregion

        #region output
        if ($AsString) {
            $Documentation.Markdown
            continue
        }

        if ($OutputPath) {
            $TargetPath = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($OutputPath)
        }
        elseif ($OutputDirectory) {
            $TargetDirectory = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($OutputDirectory)
            if ($PSCmdLet.ParameterSetName -eq 'FromFolder') {
                # Preserve the source directory structure relative to -Path, like bicep docs generate --outdir
                $RelativeDirectory = [System.IO.Path]::GetRelativePath($SourceRoot, $SourceFile.DirectoryName)
                if ($RelativeDirectory -ne '.') {
                    $TargetDirectory = Join-Path $TargetDirectory $RelativeDirectory
                }
            }
            $TargetPath = Join-Path $TargetDirectory $Documentation.OutputFileName
        }
        else {
            $TargetPath = Join-Path $SourceFile.DirectoryName $Documentation.OutputFileName
        }

        if (-not $EmittedTargets.Add($TargetPath)) {
            Write-Error -Message "Skipping $($SourceFile.Name) - the output file '$TargetPath' was already generated from another Bicep file. Use bicepconfig.json 'documentation.output.file' or -OutputPath to disambiguate."
            continue
        }

        if ((Test-Path -Path $TargetPath) -and -not $Force.IsPresent) {
            Write-Error -Message "Skipping $($SourceFile.Name) - the output file '$TargetPath' already exists. Use -Force to overwrite it."
            continue
        }

        $TargetDirectory = Split-Path -Path $TargetPath -Parent
        if (-not (Test-Path -Path $TargetDirectory)) {
            $null = New-Item -Path $TargetDirectory -ItemType Directory -Force
        }

        # Write directly to preserve the generator's deterministic output (LF endings, single trailing newline, UTF-8 without BOM)
        [System.IO.File]::WriteAllText($TargetPath, $Documentation.Markdown)
        Get-Item -Path $TargetPath
        #endregion
    }
}
