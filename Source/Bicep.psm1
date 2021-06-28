# import classes
foreach ($function in (Get-ChildItem "$PSScriptRoot\Classes\*.ps1"))
{
	. $function.FullName
	#$ExecutionContext.InvokeCommand.InvokeScript($false, ([scriptblock]::Create([io.file]::ReadAllText($function))), $null, $null)
}

# import private functions
foreach ($function in (Get-ChildItem "$PSScriptRoot\Private\*.ps1"))
{
	. $function.FullName
	# $ExecutionContext.InvokeCommand.InvokeScript($false, ([scriptblock]::Create([io.file]::ReadAllText($function))), $null, $null)
}

# import public functions
foreach ($function in (Get-ChildItem "$PSScriptRoot\Public\*.ps1"))
{
	. $function.FullName
	# $ExecutionContext.InvokeCommand.InvokeScript($false, ([scriptblock]::Create([io.file]::ReadAllText($function))), $null, $null)
}

# cache bicep types
$null = GetBicepTypes -Path "$PSScriptRoot\Assets\BicepTypes.json"
