function GetGithubReleaseVersion {
    [CmdletBinding()]
    param(
        [string]$Organization,
        [string]$Repository,
        [switch]$Latest
    )
    $Url = 'https://api.github.com/repos/{0}/{1}/releases' -f $Organization, $Repository
    if ($Latest.IsPresent) {
        $Url = '{0}/latest' -f $Url
    }
    try {
        $Versions = Invoke-RestMethod -Uri $Url -ErrorAction 'Stop'
        return ($Versions.tag_name -replace '[v]', '') -as [version]
    }
    catch {
        Write-Error -Message "Could not get version of $Organization/$Repository from GitHub. $_" -Category ObjectNotFound
    }
}