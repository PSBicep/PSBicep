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
        [ValidateSet('PSObject', 'Json', 'Hashtable')]
        [String]
        $OutputType = 'PSObject',

        [switch]$IncludeReservedMetadata
    )
    
    process {
        $file = Get-Item -Path $Path
        try {
            $BuildResult = Build-BicepFile -Path $file.FullName -NoRestore:$NoRestore.IsPresent
            $ARMTemplate = $BuildResult.Template
            $ARMTemplateObject = ConvertFrom-Json -InputObject $ARMTemplate
            $templateMetadata=$ARMTemplateObject.metadata

            if (!$IncludeReservedMetadata.IsPresent) {
                $templateMetadata=Select-Object -InputObject $templateMetadata -ExcludeProperty '_*'
            } 
        }
        catch {
            # We don't care about errors here.
        }        

        switch ($OutputType) {
            'PSObject' {
                $templateMetadata
            }
            'Json' {
                $templateMetadata | ConvertTo-Json
            }
            'Hashtable' {
                $templateMetadata | ConvertToHashtable -Ordered
            }
        }
    }
}