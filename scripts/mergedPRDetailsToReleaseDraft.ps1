[CmdletBinding()]
param (
    [Parameter()]
    [string]$CommitMessage,
    [string]$Token
)

$header = @{
    "authorization" = "token $Token"
    "Accept"        = "application/vnd.github.v3+json"
}

#Get all releases including drafts
$getReleases = Invoke-RestMethod -Method Get -Headers $header -URI  "https://api.github.com/repos/StefanIvemo/BicepPowerShell/releases"

#Check if a release draft exists
foreach ($release in $getReleases) {
    if ($release.draft -and ($release.tag_name -eq "vNext")) {
        Write-Verbose "Found draft with id $($release.id)"
        $releaseId = $release.id
        $releaseBody = $release.body
    }
}

#Parse commit message
$FirstLine, $Rest = $CommitMessage -split '\n', 2 | Foreach-Object -MemberName Trim
$PR = $FirstLine -replace '.*(#\d+).*', '$1'
$releaseMessage = $Rest

#Get PR details from commit
$prNumber = ($PR -split "#")[1]
$getPullRequest = Invoke-RestMethod -Method Get -URI  "https://api.github.com/repos/StefanIvemo/BicepPowerShell/pulls/$prNumber"
$prLabel = $getPullRequest.labels.name
Write-Verbose "Found Pull Request"
Write-Verbose "PR Number: $($getPullRequest.number)" 
Write-Verbose "PR Label: $prLabel"
Write-Verbose "PR Author: $($getPullRequest.user.login)"

#Commit details
$mergedCommit = [ordered]@{
    prNumber      = $prNumber
    commitMessage = $releaseMessage
    commitAuthor  = $getPullRequest.user.login
    mergedDate    = $getPullRequest.merged_at
}

#Only process PRs with labels assigned
if ($prLabel -eq 'bugFix' -or $prLabel -eq 'newFeature' -or $prLabel -eq 'updatedDocs') {
    if (-not [string]::IsNullOrWhiteSpace($releaseBody)) {
        Write-Verbose "Updating release draft body"
        $releaseBody = $releaseBody | ConvertFrom-Json -AsHashtable -Depth 10
        $releaseBody[$prLabel] += $mergedCommit
    }
    else {
        Write-Verbose "Creating new release draft body"
        $releaseBody = @{
            newFeature  = @()
            bugFix      = @()
            updatedDocs = @()  
        }
        $releaseBody[$prLabel] += $mergedCommit   
    }
    $releaseBody = $releaseBody | ConvertTo-Json -Depth 10
    
    $body = @{
        tag_name = "vNext"
        name     = "WIP - Next Release"
        body     = $releaseBody
        draft    = $true
    }
    $requestBody = ConvertTo-Json $body -Depth 10
    
    if (!$releaseId) {
        $createRelease = Invoke-RestMethod -Method Post -Headers $Header -Body $requestBody -URI  "https://api.github.com/repos/StefanIvemo/BicepPowerShell/releases" -Verbose
        Write-Verbose "New releasedraft created"
    }
    else {
        $updateRelease = Invoke-RestMethod -Method Patch -Headers $Header -Body $requestBody -URI  "https://api.github.com/repos/StefanIvemo/BicepPowerShell/releases/$releaseId" -Verbose
        Write-Verbose "Updated release draft with $PR"
    }
} else {
    Write-Host "No PR label found, or PR Label ignored"
}