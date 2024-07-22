function New-BicepMarkdownDocumentation {
    [CmdletBinding(DefaultParameterSetName = 'FromFile')]
    param (
        [Parameter(ParameterSetName = 'FromFile', Position = 0)]
        [string]$File,

        [Parameter(ParameterSetName = 'FromFolder', Position = 0)]
        [string]$Path,

        [Parameter(ParameterSetName = 'FromFolder')]
        [switch]$Recurse,

        [Parameter(ParameterSetName = 'FromFile')]
        [Parameter(ParameterSetName = 'FromFolder')]
        [switch]$AsString,

        [Parameter(ParameterSetName = 'FromFile')]
        [Parameter(ParameterSetName = 'FromFolder')]
        [switch]$Force
    )

    switch ($PSCmdLet.ParameterSetName) {
        'FromFile' { 
            [System.IO.FileInfo[]]$FileCollection = Get-Item $File
        }
        'FromFolder' { 
            [System.IO.FileInfo[]]$FileCollection = Get-ChildItem $Path *.bicep -Recurse:$Recurse
        }
    }

    Write-Verbose -Verbose "Files to process:`n$($FileCollection.Name)"

    $MDHeader = @'
# {{SourceFile}}

[[_TOC_]]

'@

    foreach ($SourceFile in $FileCollection) {
        $FileDocumentationResult = $MDHeader.Replace('{{SourceFile}}', $SourceFile.Name)

        #region build Bicep PS object
        try {
            $BuildObject = (Build-BicepFile -Path $SourceFile.FullName -ErrorAction Stop) | ConvertFrom-Json -Depth 100
        }
        catch {
            Write-Error -Message "Failed to build $($SourceFile.Name) - $($_.Exception.Message)"
            
            switch ($ErrorActionPreference) {
                'Stop' { throw }
                default { continue }
            }
        }
        #endregion

        #region Get used modules in the bicep file

        $UsedModules = Get-BicepUsedModules -Path $SourceFile.FullName -ErrorAction Stop 

        #endregion

        #region Add Metadata to MD output

        $MDMetadata = NewMDMetadata -Metadata $BuildObject.metadata

        $FileDocumentationResult += @"
## Metadata

$MDMetadata
"@

        #endregion

        #region Add providers to MD output

        $MDProviders = NewMDProviders -Providers $BuildObject.resources

        $FileDocumentationResult += @"

## Providers

$MDProviders
"@
        #endregion

        #region Add Resources to MD output

        $MDResources = NewMDResources -Resources $BuildObject.resources

        $FileDocumentationResult += @"

## Resources

$MDResources
"@
        #endregion

        #region Add Parameters to MD output

        $MDParameters = NewMDParameters -Parameters $BuildObject.parameters

        $FileDocumentationResult += @"

## Parameters

$MDParameters
"@
        #endregion

        #region Add Variables to MD output

        $MDVariables = NewMDVariables -Variables $BuildObject.variables

        $FileDocumentationResult += @"

## Variables

$MDVariables
"@
        #endregion

        #region Add Outputs to MD output

        $MDOutputs = NewMDOutputs -Outputs $BuildObject.outputs

        $FileDocumentationResult += @"

## Outputs

$MDOutputs
"@
        #endregion

        #region Add Modules to MD output

        $MDModules = NewMDModules -Modules $UsedModules

        $FileDocumentationResult += @"

## Modules

$MDModules
"@

        #endregion

        #region output
        if ($AsString) {
            $FileDocumentationResult
        }
        else {
            $OutFileName = $SourceFile.FullName -replace '\.bicep$', '.md'
            $FileDocumentationResult | Out-File $OutFileName
        }
        #endregion
    }
}
