function Publish-Bicep {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({Test-Path $_})]
        [string]$Path,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^(?<Prefix>[bBrR]{2})(?<ACROrAlias>(:[\w\-_]+\.azurecr.io|\/[\w\-\._]+:))(?<path>[\w\/\-\._]+)(?<tag>:[\w\/\-\._]+)$', ErrorMessage = 'Target does not match pattern for registry. Specify a path to a registry using "br:", or "br/" if using an alias.')]
        [string]$Target,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$DocumentationUri,

        [Parameter()]
        [switch]$PublishSource,

        [Parameter()]
        [switch]$Force
    )

    begin {    
        # This command currently uses native Bicep authentication for now
        # AssertAzureConnection -TokenSplat $script:TokenSplat
    }

    process {
        $BicepFile = Get-Childitem -Path $Path -File
            
        try {
            $validBicep = Test-BicepFile -Path $BicepFile.FullName -IgnoreDiagnosticOutput -AcceptDiagnosticLevel Warning -Verbose:$false
            if (-not ($validBicep)) {
                throw "The provided bicep is not valid. Make sure that your bicep file builds successfully before publishing."
            }
            else {
                Write-Verbose "[$($BicepFile.Name)] is valid"
            }
        }
        catch {
            $_.CategoryInfo.Activity = 'Publish-Bicep'
            Throw $_
        }

        if ($VerbosePreference -eq [System.Management.Automation.ActionPreference]::Continue) {
            $bicepConfig= Get-BicepConfig -Path $BicepFile
            Write-Verbose -Message "Using Bicep configuration: $($bicepConfig.Path)"
        }

        # Publish module
        $PublishParams = @{
            Path = $BicepFile.FullName
            Target = $Target
            PublishSource = $PublishSource.IsPresent
            Force = $Force.IsPresent
        }
        if($PSBoundParameters.ContainsKey('DocumentationUri')) {
            $PublishParams.Add('DocumentationUri', $DocumentationUri)
        }
        try {
            Publish-BicepFile @PublishParams -ErrorAction Stop
            Write-Verbose -Message "[$($BicepFile.Name)] published to: [$Target]"
        }
        catch {
            $_.CategoryInfo.Activity = 'Publish-Bicep'
            throw $_
        }
    }
}