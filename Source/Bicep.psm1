# import classes
foreach ($file in (Get-ChildItem "$PSScriptRoot\Classes\*.ps1"))
{
	try {
		Write-Verbose "Importing $($file.FullName)"
		. $file.FullName
	}
	catch {
		Write-Error "Failed to import '$($file.FullName)'. $_"
	}
}

# import private functions
foreach ($file in (Get-ChildItem "$PSScriptRoot\Private\*.ps1"))
{
	try {
		Write-Verbose "Importing $($file.FullName)"
		. $file.FullName
	}
	catch {
		Write-Error "Failed to import '$($file.FullName)'. $_"
	}
}

# import public functions
foreach ($file in (Get-ChildItem "$PSScriptRoot\Public\*.ps1"))
{
	try {
		Write-Verbose "Importing $($file.FullName)"
		. $file.FullName
	}
	catch {
		Write-Error "Failed to import '$($file.FullName)'. $_"
	}
}
