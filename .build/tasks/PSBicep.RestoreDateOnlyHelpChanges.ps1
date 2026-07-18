param (
    [switch]$AgainstHead
)

task PSBicep.RestoreDateOnlyPlatyPSChanges {
    $ErrorActionPreference = 'Stop'
    $PSNativeCommandUseErrorActionPreference = $true

    if (-not (Get-Command git -CommandType Application -ErrorAction SilentlyContinue)) {
        Write-Warning 'Git is required but was not found in PATH.'
        exit
    }

    # Identify the root of the repo
    $repoRoot = git rev-parse --show-toplevel

    $comparison = $AgainstHead ? @('HEAD') : @()
    $action = $AgainstHead ? 'Restore staged and unstaged changes from HEAD' : 'Restore unstaged changes from the index'
    $restoreArguments = $AgainstHead ? @('--source=HEAD', '--staged', '--worktree') : @('--worktree')

    $files = @(git -C $repoRoot diff --name-only --diff-filter=M @comparison -- 'Docs/Bicep/*.md')

    foreach ($file in $files) {
        $changedLines = @(git -C $repoRoot diff --unified=0 @comparison -- $file |
            Where-Object { $_ -match '^[+-]' -and $_ -notmatch '^(\+\+\+|---)' })

        if (
            $changedLines.Count -gt 0 -and
            @($changedLines | Where-Object { $_ -notmatch '^[+-]ms\.date:\s*.+$' }).Count -eq 0 -and
            $PSCmdlet.ShouldProcess($file, $action)
        ) {
            git -C $repoRoot restore @restoreArguments -- $file
            Write-Output "Restored $file"
        }
    }
}
