function updateHelpUri
{
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$Path,
        [string]$VersionToReplace,
        [string]$NewVersion
    )
    
    $files = Get-ChildItem -Path $Path -Recurse
    foreach($file in $files) {
        $string = Get-Content -Path $file.FullName | Select-String -pattern 'HelpUri' -SimpleMatch

        $string = $string -replace ".*HelpUri|HelpUri|\]|\)|'|=|\s+",''
        $stringToReplace = $string
        $stringToSave = $string.Replace($VersionToReplace,$NewVersion)

        $NewContent = (Get-Content -Path $file.FullName).Replace($stringToReplace,$stringToSave)

        Set-Content -Path $file.FullName -Value $NewContent -Force
    }
}

