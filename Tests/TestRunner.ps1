param (
    [ValidateScript( { $_ -like '*.Tests.ps1' },
        ErrorMessage = "Path must be a valid test file: *.Tests.ps1")] 
    [ValidateNotNullOrEmpty()]
    [string[]]$Path,

    [ValidateSet('None', 'Normal', 'Detailed', 'Diagnostic')]
    [string]$Verbosity = 'Detailed',

    [switch]$CodeCoverage,

    [switch]$UseJaCoCo,

    [switch]$TestResults
)

Import-Module -Name 'Pester'

if ($UseJaCoCo.IsPresent -and -not ($CodeCoverage.IsPresent)) {
    Throw 'UseJaCoCo requires CodeCoverage'
}

$ScriptFiles = [System.Collections.ArrayList]::new()
$TestFiles   = [System.Collections.ArrayList]::new()

$RootPath = Split-Path -Path $PSScriptRoot -Parent

$ScriptFolders = @(
    # ChildPath must include an asterisk (*) to get the include filter to work with Get-ChildItem later
    Join-Path -Path $RootPath -ChildPath 'Source\Private\*.ps1'
    Join-Path -Path $RootPath -ChildPath 'Source\Public\*.ps1'
)

if ($PSBoundParameters.ContainsKey('Path')) {
    # Prepare test and coverage files
    foreach ($TestFilePath in $Path) {
        # if the file exist, add it to the TestFiles list
        try {
            $TestFile = Get-ChildItem -Path $TestFilePath -File
        }
        catch {
            Throw "Could not find test file '$TestFilePath'. $_"
        }
        Write-Verbose "Found test file '$($TestFile.FullName)'"
        $null = $TestFiles.Add($TestFile.FullName)

        if ($CodeCoverage.IsPresent) {
            # Find the file we should use for code coverage and add it to the ScriptFiles list
            $CoverageFileName = $TestFile.Name -replace '.tests.ps1','.ps1'

            try {
                $CoverageFile = Get-ChildItem -Path $ScriptFolders -Include $CoverageFileName -File
                if ($CoverageFile -is [array]) {
                    Throw "Found multiple matches."
                }
                elseif ($null -eq $CoverageFile){
                    Throw "Not found."
                }
            }
            catch {
                Throw "Error trying to find script file for code coverage ($CoverageFileName). $_"
            }
            Write-Verbose "Found coverage file '$($CoverageFile.FullName)'"
            $null = $ScriptFiles.Add($CoverageFile.FullName)
        }
    }
}
else {
    $null = $ScriptFiles.AddRange((Get-ChildItem $ScriptFolders).FullName)
}

# Create Pester configuration
$PesterConfiguration = [PesterConfiguration]::new()
$PesterConfiguration.Output.Verbosity = $Verbosity

#Exclude integration tests
$excludePath=Join-Path -Path $RootPath -ChildPath 'Source\IntegrationTests\'
$PesterConfiguration.Run.ExcludePath = "$excludePath*"

if ($TestFiles.Count -gt 0) {
    $PesterConfiguration.Run.Path = $TestFiles.ToArray()
}

if ($TestResults.IsPresent) {
    Write-Verbose "Enabling test result"
    $PesterConfiguration.TestResult.Enabled = $true
    $PesterConfiguration.TestResult.OutputFormat = 'JUnitXml'
}

if ($CodeCoverage.IsPresent) {
    Write-Verbose "Enabling code coverage"
    $PesterConfiguration.CodeCoverage.Enabled = $true
    $PesterConfiguration.CodeCoverage.Path = $ScriptFiles.ToArray()
    $PesterConfiguration.CodeCoverage.CoveragePercentTarget = 75
    $PesterConfiguration.CodeCoverage.OutputPath = "$PSScriptRoot/coverage.xml"

    if ($UseJaCoCo.IsPresent) {
        $PesterConfiguration.CodeCoverage.OutputFormat = 'JaCoCo'
    }
    else {
        $PesterConfiguration.CodeCoverage.OutputFormat = 'CoverageGutters'
    }
}

Invoke-Pester -Configuration $PesterConfiguration
