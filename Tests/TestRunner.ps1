Import-Module -Name 'Pester'

$PesterConfiguration = [PesterConfiguration]::new()
$PesterConfiguration.TestResult.Enabled = $true
$PesterConfiguration.TestResult.OutputFormat = 'JUnitXml'

Invoke-Pester -Configuration $PesterConfiguration