param (
    [string[]]
    $Path = @('PSBicep.Core', 'PSBicep'),

    [ValidateSet('Debug', 'Release')]
    [string]
    $Configuration = (property CompileConfiguration 'Release'),

    [Switch]
    $Full,

    [switch]
    $ClearNugetCache
)

task PSBicep.Restore {
    Write-Verbose "Configuration: $Configuration" -Verbose
    if($ClearNugetCache) {
        dotnet nuget locals all --clear
    }
    if ($Full) {
        dotnet build-server shutdown
    }

    foreach ($projPath in $Path) {
        $outPathFolder = Split-Path -Path (Resolve-Path -Path $projPath) -Leaf
        Write-Host $projPath
        Write-Host $outPathFolder
        $outPath = "bin/$outPathFolder"
        if (-not (Test-Path -Path $projPath)) {
            throw "Path '$projPath' does not exist."
        }

        Push-Location -Path $projPath

        if ($Full -and (Test-Path -Path $outPath)) {
            # Remove output folder if exists
            Remove-Item -Path $outPath -Recurse -Force
        }

        Write-Host "Restoring '$projPath'" -ForegroundColor 'Magenta'
        dotnet restore --force-evaluate "--property:NuGetAudit=false"

        Pop-Location
    }
}
