function GetBicepTypes {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )
    
    if (-not [string]::IsNullOrEmpty($Path)) {
        Write-Verbose "Importing Bicep Types"
        $types = Get-Content -Path $Path | ConvertFrom-Json -AsHashtable
        $types = $types.Types

        $allResourceProviders = [System.Collections.ArrayList]::new()
        
        foreach ($type in $types.Keys) {        
            $ResourceProviders = [PSCustomObject]@{
                ResourceProvider = ($type -split "/")[0]
                Resource = (($type -split "/")[1] -split '@')[0]
                ApiVersion = ($type -split "@")[1]
            }
            $null = $allResourceProviders.Add($ResourceProviders)
        }
        $Global:BicepResourceProviders = $allResourceProviders
    }

    Write-Output -InputObject $Global:BicepResourceProviders
}

