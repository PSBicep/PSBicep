# import private functions
foreach ($function in (Get-ChildItem "$PSScriptRoot\Private\*.ps1"))
{
	$ExecutionContext.InvokeCommand.InvokeScript($false, ([scriptblock]::Create([io.file]::ReadAllText($function))), $null, $null)
}

# import public functions
foreach ($function in (Get-ChildItem "$PSScriptRoot\Public\*.ps1"))
{
	$ExecutionContext.InvokeCommand.InvokeScript($false, ([scriptblock]::Create([io.file]::ReadAllText($function))), $null, $null)
}

$Script:ResourceProviders = ProcessBicepTypes