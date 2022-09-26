function Get-BicepMetadata {
    [CmdletBinding()]
    param (
        # Specifies a path to one or more locations.
        [Parameter(
            Mandatory = $true
        )]
        [Alias("PSPath")]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path,

        # Set output type
        [Parameter()]
        [ValidateSet('Simple', 'Json', 'Hashtable')]
        [String]
        $OutputType = 'Simple',

        [switch]$SkipGeneratorMeta
    )
    
    begin {
        if (-not $Script:ModuleVersionChecked) {
            TestModuleVersion
        }

        if ($VerbosePreference -eq [System.Management.Automation.ActionPreference]::Continue) {
            $FullVersion = Get-BicepNetVersion -Verbose:$false
            Write-Verbose -Message "Using Bicep version: $FullVersion"
        }
    }
    
    process {
        $file = Get-Item -Path $Path
        try {  
       
            $BuildResult = Build-BicepNetFile -Path $file.FullName

            $ARMTemplate = $BuildResult[0]
            $ARMTemplateObject = ConvertFrom-Json -InputObject $ARMTemplate
            $templateMetadata=$ARMTemplateObject.metadata

            if ($SkipGeneratorMeta.IsPresent) {
                $templateMetadata.PSObject.Properties.Remove('_generator')
            }
        }
        catch {
            # We don't care about errors here.
        }        

        switch ($OutputType) {
            'Simple' {
                $ARMTemplateObject.metadata
            }
            'Json' {
                $ARMTemplateObject.metadata | ConvertTo-Json
            }
            'Hashtable' {
                $ARMTemplateObject.metadata | ConvertToHashtable -Ordered
            }
        }
    }
}