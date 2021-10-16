function New-BicepMarkdownDocumentation {
    [CmdletBinding(DefaultParameterSetName='FromFile')]
    param (
        [Parameter(ParameterSetName = 'FromFile', Position = 0)]
        [string]$File,

        [Parameter(ParameterSetName = 'FromFolder', Position = 0)]
        [string]$Path,

        [Parameter(ParameterSetName = 'FromFolder')]
        [switch]$Recurse,

        [Parameter(ParameterSetName = 'FromFile')]
        [Parameter(ParameterSetName = 'FromFolder')]
        [switch]$Console,

        [Parameter(ParameterSetName = 'FromFile')]
        [Parameter(ParameterSetName = 'FromFolder')]
        [switch]$Force
    )

    function NewMDTableHeader {
        param(
            [string[]]$Headers
        )

        $r = '|'
        foreach ($Head in $Headers) {
            $r += " $Head |"
        }
        
        $r = "$r`n|"
        
        1..($Headers.Count) | foreach {
            $r += "----|"
        }

        $r = "$r`n"
        
        $r
    }

    switch ($PSCmdLet.ParameterSetName) {
        'FromFile' { 
            $FileCollection = @((Get-Item $File)) 
        }
        'FromFolder' { 
            $FileCollection = Get-ChildItem $Path *.bicep -Recurse:$Recurse
        }
    }

    Write-Verbose "Files to process:`n$($FileCollection.Name)"

    $MDHeader = @'
# {{SourceFile}}

[[_TOC_]]

'@

    foreach ($SourceFile in $FileCollection) {
        $FileDocumentationResult = $MDHeader.Replace('{{SourceFile}}', $SourceFile.Name)
        
        $MDProviders = NewMDTableHeader -Headers 'Name', 'Version'
        $MDResources = NewMDTableHeader -Headers 'Name', 'Type'
        $MDInputs = NewMDTableHeader -Headers 'Name', 'Description', 'Type', 'Default', 'Required'
        $MDOutputs = [string]::Empty

        $BuildObject = (Build-BicepNetFile -Path $SourceFile.FullName).Template | ConvertFrom-Json

#region Add providers to MD output
        foreach ($provider in $BuildObject.resources) {
            $MDProviders += "| $($Provider.Type) | $($Provider.apiVersion) |`n"
        }
        $FileDocumentationResult += @"

## Providers

$MDProviders
"@
#endregion

#region Add Resources to MD output
        foreach ($Resource in $BuildObject.resources) {
            $URI = Get-BicepApiReference -Type "$($BuildObject.resources.Type)@$($BuildObject.resources.apiVersion)" -ReturnUri
            $MDResources += "| [$($Provider.Type)@$($Provider.apiVersion)]($URI) | $($Provider.kind) |`n"
        }
$FileDocumentationResult += @"

## Resources

$MDResources
"@
#endregion

#region Add inputs to MD output
        $InputNames = ($BuildObject.parameters | Get-Member -MemberType NoteProperty).Name
        foreach ($Input in $InputNames) {
            $Param = $BuildObject.parameters.$Input
            $MDInputs += "| $Input | $($Param.Description) | $($Param.type) | $($Param.defaultValue) | $($Param.required) |`n"
        }
$FileDocumentationResult += @"

## Inputs

$MDInputs
"@
#endregion

#region Add outputs to MD output
        $OutputNames = ($BuildObject.Outputs | Get-Member -MemberType NoteProperty).Name
        foreach ($OutputName in $OutputNames) {
            $MDOutputs += "$OutputName`n"
        }
$FileDocumentationResult += @"

## Outputs

$MDOutputs
"@
#endregion

        if ($Console) {
            $FileDocumentationResult
        }
        else {
            $OutFileName = $SourceFile.FullName -replace '\.bicep$','.md'
            $FileDocumentationResult | Out-File $OutFileName
        }
    }
}