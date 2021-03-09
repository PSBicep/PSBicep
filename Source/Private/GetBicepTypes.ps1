function GetBicepTypes {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )
    
    if (-not [string]::IsNullOrEmpty($Path)) {
        Write-Verbose "Importing Bicep Types"
        $types = Get-Content -Path $Path | ConvertFrom-Json -AsHashtable

        $allResourceProviders = [System.Collections.ArrayList]::new()
        
        foreach ($type in $types) {
            # Type looks like this:  Microsoft.Aad/domainServicess@2017-01-01
            # We want to split here:              ^               ^
            # Or like this:          Microsoft.ApiManagement/service/certificates@2019-12-01
            # Then we split here:                           ^       ^            ^
            
            # First check if we have three parts before the @
            # In that case the last one should be the child
            if (($type -split '/' ).count -eq 3) {
                $child = ( ($type -split '@') -split '/' )[2]
            }  
            else {
                $child = $null
            }

            $ResourceProviders = [PSCustomObject]@{
                ResourceProvider = ( ($type -split '@') -split '/' )[0]
                Resource         = ( ($type -split '@') -split '/' )[1]
                Child            = $child
                ApiVersion       = ( $type -split '@' )[1]
                FullName         = $type
            }
            
            $null = $allResourceProviders.Add($ResourceProviders)
        }
        $Script:BicepResourceProviders = $allResourceProviders
    }

    Write-Output -InputObject $Script:BicepResourceProviders
}

