function New-BicepMarkdownDocumentation {
    [CmdletBinding(DefaultParameterSetName = 'Default', SupportsShouldProcess)]
    [OutputType([System.IO.FileInfo], [string])]
    param (
        [Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [SupportsWildcards()]
        [Alias('FullName')]
        [ValidateNotNullOrEmpty()]
        [string[]]$Path = $pwd.Path,

        [switch]$Recurse,

        [Parameter(ParameterSetName = 'AsString', Mandatory)]
        [switch]$AsString,

        [Parameter(ParameterSetName = 'OutputPath', Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$OutputPath,

        [Parameter(ParameterSetName = 'OutputDirectory', Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$OutputDirectory,

        [ValidateNotNullOrEmpty()]
        [string]$TemplateFile,

        [ValidateNotNullOrEmpty()]
        [string]$TemplateRoot,

        [hashtable]$CustomValue,

        [string[]]$CustomValueFilePath,

        [switch]$NoRestore,

        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'OutputPath')]
        [Parameter(ParameterSetName = 'OutputDirectory')]
        [switch]$Force
    )

    begin {
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

        # Tracked across the whole pipeline so that two bicep files resolving to the same output
        # file are reported instead of silently overwriting each other.
        $EmittedTargets = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
        $OutputPathTaken = $false
    }

    process {
        foreach ($InputPath in $Path) {
            #region Resolve the input path to the bicep files it represents
            # -ErrorAction Ignore so that only the error below reaches the caller
            $ResolvedPaths = @(Resolve-Path -Path $InputPath -ErrorAction Ignore).ProviderPath

            if ($ResolvedPaths.Count -eq 0) {
                Write-Error -Message "Failed to resolve path '$InputPath' - the path does not exist."
                continue
            }

            # A folder or a wildcard means "every bicep file that matches", so anything else is
            # filtered out. A path naming a single file is taken as given.
            $IsWildcard = [System.Management.Automation.WildcardPattern]::ContainsWildcardCharacters($InputPath)

            foreach ($ResolvedPath in $ResolvedPaths) {
                if (Test-Path -LiteralPath $ResolvedPath -PathType Container) {
                    # Documentation is laid out relative to the folder that was asked for
                    $SourceRoot = $ResolvedPath
                    $SourceFiles = @(Get-ChildItem -LiteralPath $ResolvedPath -Filter '*.bicep' -File -Recurse:$Recurse)

                    if ($SourceFiles.Count -eq 0) {
                        Write-Warning "No bicep files found in '$ResolvedPath'."
                        continue
                    }
                }
                else {
                    $SourceFile = Get-Item -LiteralPath $ResolvedPath
                    if ($IsWildcard -and $SourceFile.Extension -ne '.bicep') {
                        continue
                    }

                    # A single file never nests below -OutputDirectory
                    $SourceRoot = $SourceFile.DirectoryName
                    $SourceFiles = @($SourceFile)
                }
                #endregion

                foreach ($SourceFile in $SourceFiles) {
                    Write-Verbose "Generating documentation for $($SourceFile.FullName)"

                    #region Generate documentation using the native Bicep documentation generator
                    try {
                        $Documentation = New-BicepDocumentation -Path $SourceFile.FullName -NoRestore:$NoRestore @DocumentationParameters -ErrorAction Stop
                    }
                    catch {
                        # Throws when $ErrorActionPreference is Stop, otherwise moves on to the next file
                        Write-Error -Message "Failed to generate documentation for $($SourceFile.Name) - $($_.Exception.Message)"
                        continue
                    }
                    #endregion

                    #region output
                    if ($AsString) {
                        $Documentation.Markdown
                        continue
                    }

                    if ($OutputPath) {
                        if ($OutputPathTaken) {
                            Write-Error -Message "Skipping $($SourceFile.Name) - -OutputPath can only be used when -Path resolves to a single bicep file. Use -OutputDirectory to document more than one file."
                            continue
                        }
                        $TargetPath = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($OutputPath)
                        $OutputPathTaken = $true
                    }
                    elseif ($OutputDirectory) {
                        $TargetDirectory = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($OutputDirectory)
                        # Preserve the source directory structure relative to the resolved source root,
                        # like bicep docs generate --outdir
                        $RelativeDirectory = [System.IO.Path]::GetRelativePath($SourceRoot, $SourceFile.DirectoryName)
                        if ($RelativeDirectory -ne '.') {
                            $TargetDirectory = Join-Path $TargetDirectory $RelativeDirectory
                        }
                        $TargetPath = Join-Path $TargetDirectory $Documentation.OutputFileName
                    }
                    else {
                        $TargetPath = Join-Path $SourceFile.DirectoryName $Documentation.OutputFileName
                    }

                    if (-not $EmittedTargets.Add($TargetPath)) {
                        Write-Error -Message "Skipping $($SourceFile.Name) - the output file '$TargetPath' was already generated from another bicep file. Use bicepconfig.json 'documentation.output.file' or -OutputPath to disambiguate."
                        continue
                    }

                    if ((Test-Path -LiteralPath $TargetPath) -and -not $Force.IsPresent) {
                        Write-Error -Message "Skipping $($SourceFile.Name) - the output file '$TargetPath' already exists. Use -Force to overwrite it."
                        continue
                    }

                    if ($PSCmdlet.ShouldProcess($TargetPath, 'Create markdown documentation')) {
                        $TargetDirectory = Split-Path -Path $TargetPath -Parent
                        if (-not (Test-Path -LiteralPath $TargetDirectory)) {
                            $null = New-Item -Path $TargetDirectory -ItemType Directory -Force
                        }

                        # Write directly to preserve the generator's deterministic output (LF endings, single trailing newline, UTF-8 without BOM)
                        [System.IO.File]::WriteAllText($TargetPath, $Documentation.Markdown)
                        Get-Item -LiteralPath $TargetPath
                    }
                    #endregion
                }
            }
        }
    }
}
