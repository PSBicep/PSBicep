Import-Module -Name 'Pester'

$functions = [System.Collections.ArrayList]::new()
$functions.AddRange((Get-ChildItem "$PSScriptRoot\..\Source\Classes\*.ps1").FullName)
$functions.AddRange((Get-ChildItem "$PSScriptRoot\..\Source\Private\*.ps1").FullName)
$functions.AddRange((Get-ChildItem "$PSScriptRoot\..\Source\Public\*.ps1").FullName)

$PesterConfiguration = [PesterConfiguration]::new()
$PesterConfiguration.TestResult.Enabled = $true
$PesterConfiguration.TestResult.OutputFormat = 'JUnitXml'
$PesterConfiguration.CodeCoverage.Enabled = $true
$PesterConfiguration.CodeCoverage.Path = $functions.ToArray()

Invoke-Pester -Configuration $PesterConfiguration