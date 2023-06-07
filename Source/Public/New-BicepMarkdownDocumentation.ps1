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
        [switch]$Console,

        [Parameter(ParameterSetName = 'FromFile')]
        [Parameter(ParameterSetName = 'FromFolder')]
        [switch]$Force
    )

    function New-MDTableHeader {
        param(
            [string[]]$Headers
        )

        $r = '|'
        foreach ($Head in $Headers) {
            $r += " $Head |"
        }
        
        $r = "$r`n|"
        
        1..($Headers.Count) | ForEach-Object {
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

    Write-Verbose -Verbose "Files to process:`n$($FileCollection.Name)"

    $MDHeader = @'
# {{SourceFile}}

[[_TOC_]]

'@

    foreach ($SourceFile in $FileCollection) {
        $FileDocumentationResult = $MDHeader.Replace('{{SourceFile}}', $SourceFile.Name)
        
        $MDMetadata = New-MDTableHeader -Headers 'Name', 'Value'
        $MDProviders = New-MDTableHeader -Headers 'Type', 'Version'
        $MDResources = New-MDTableHeader -Headers 'Name', 'Link', 'Location'
        $MDParameters = New-MDTableHeader -Headers 'Name', 'Type', 'AllowedValues', 'Metadata'
        $MDVariables = New-MDTableHeader -Headers 'Name', 'Value'
        $MDOutputs = New-MDTableHeader -Headers 'Name', 'Type', 'Value'

        $BuildObject = (Build-BicepNetFile -Path $SourceFile.FullName) | ConvertFrom-Json -Depth 100

        #region Add providers to MD output
        foreach ($provider in $BuildObject.resources) {
            $MDProviders += "| $($Provider.Type) | $($Provider.apiVersion) |`n"
        }

        $MDMetadata += forEach ($prop in $BuildObject.metadata.PSObject.Properties | Where-Object { $_.MemberType -eq 'NoteProperty' -and $_.Name -ne '_generator' }) {
            ("|$($prop.Name)|$($prop.Value)|").Trim() + "`n"
        }


        # metadata: @{_generator=; type=deployment; name=main.bicep; description=Main deployment bicep file - deploys all the modules, requires a resource group to exist}

        $FileDocumentationResult += @"
## Metadata

$MDMetadata
"@

        $FileDocumentationResult += @"

## Providers

$MDProviders
"@
        #endregion

        #region Add Resources to MD output
        foreach ($Resource in $BuildObject.resources) {
            try {
                $URI = Get-BicepApiReference -Type "$($Resource.Type)@$($Resource.apiVersion)" -ReturnUri -Force
            }
            catch {
                # If no uri is found this is the base path for template
                $URI = 'https://docs.microsoft.com/en-us/azure/templates'
            }
            $MDResources += "| $($Resource.name) | [$($Resource.Type)@$($Resource.apiVersion)]($URI) | $($Resource.location) |`n"
        }
        $FileDocumentationResult += @"

## Resources

$MDResources
"@
        #endregion

        #region Add Parameters to MD output
        if ($null -eq $BuildObject.parameters) {
            $MDParameters = 'n/a'
        }
        else {
            $ParameterNames = ($BuildObject.parameters | Get-Member -MemberType NoteProperty).Name

            foreach ($Parameter in $ParameterNames) {
                $Param = $BuildObject.parameters.$Parameter
                $MDParameters += "| $Parameter | $($Param.type) | $(
                    if ($Param.allowedValues) {
                        forEach ($value in $Param.allowedValues) {
                                                                    "$value <br>"
                        }
                    } else {
                        "n/a"
                    }
                    ) | $(
                    forEach ($item in $Param.metadata) {
                            $res = $item.PSObject.members | Where-Object { $_.MemberType -eq 'NoteProperty' }
                            
                            if ($null -ne $res) {
                            
                                $res.Name + ': ' + $res.Value + '<br>'
                            
                            }
                    }) |`n" 
            }
        }

        $FileDocumentationResult += @"

## Parameters

$MDParameters
"@
        #endregion

        #region Add Variables to MD output
        if ($null -eq $BuildObject.variables) {
            $MDVariables = 'n/a'
        }
        else {
            $VariableNames = ($BuildObject.variables | Get-Member -MemberType NoteProperty).Name
            foreach ($var in $VariableNames) {
                $Param = $BuildObject.variables.$var
                $MDVariables += "| $var | $Param |`n"
            }
        }
        $FileDocumentationResult += @"

## Variables

$MDVariables
"@
        #endregion

        #region Add outputs to MD output
        if ($null -eq $BuildObject.Outputs) {
            $MDOutputs = 'n/a'
        }
        else {
            $OutputNames = ($BuildObject.Outputs | Get-Member -MemberType NoteProperty).Name
            foreach ($OutputName in $OutputNames) {
                $OutputValues = $BuildObject.outputs.$OutputName
                $MDOutputs += "| $OutputName | $($OutputValues.type) | $($OutputValues.value) |`n"
            }
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
            $OutFileName = $SourceFile.FullName -replace '\.bicep$', '.md'
            $FileDocumentationResult | Out-File $OutFileName
        }
    }
}