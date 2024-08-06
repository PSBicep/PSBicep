function ListBicepVersions {
    [CmdletBinding()]
    param (
        [switch]$Latest
    )
    if($null -eq $Script:AvailableBicepVersions) {
        try {
            $Script:AvailableBicepVersions = GetGithubReleaseVersion -Organization 'Azure' -Repository 'bicep' -ErrorAction 'Stop'
        }
        catch {
            $Script:AvailableBicepVersions = @()
            Write-Verbose "Failed to retrieve versions with error: $_"
        }
    }

    if($null -eq $Script:LatestBicepVersion) {
        try {
            $Script:LatestBicepVersion = GetGithubReleaseVersion -Organization 'Azure' -Repository 'bicep' -Latest -ErrorAction 'Stop'
        }
        catch {
            $Script:LatestBicepVersion = ''
            Write-Verbose "Failed to retrieve latest version with error: $_"
        }
    }
    
    if($Latest.IsPresent -and $Script:LatestBicepVersion -is [version]) {
        Write-Output -InputObject $Script:LatestBicepVersion
    }
    else {
        Write-Output -InputObject $Script:AvailableBicepVersions
    }
}