function Convert-JsonToBicep {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,
            ValueFromPipeline = $true,
            ParameterSetName = 'String')]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                try { $_ | Convertfrom-Json }
                catch { $false }
            },
            ErrorMessage = 'The string is not a valid json')]
        [string]$String,
        [Parameter(ParameterSetName = 'Path')]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                try { Get-Content -Path $_ | Convertfrom-Json }
                catch { $false }
            },
            ErrorMessage = 'The file does not contain a valid json')]
        [string]$Path,
        [switch]$ToClipboard
    )

    begin {
        if (-not $Script:ModuleVersionChecked) {
            TestModuleVersion
        }
        $tempPath = [System.Io.Path]::GetTempPath()
    }

    process {

        if($String) {
            $inputObject = $String | ConvertFrom-Json
        }
        else {
            $inputObject = Get-Content -Path $Path | ConvertFrom-Json
        }

        if ((-not $IsWindows) -and $ToClipboard.IsPresent) {
            Write-Error -Message "The -ToClipboard switch is only supported on Windows systems."
            break
        }

        $hashTable = ConvertToHashtable -InputObject $inputObject -Ordered
        $variables = [ordered]@{}
        $templateBase = [ordered]@{
            '$schema'        = 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
            'contentVersion' = '1.0.0.0'
        }
        $variables['temp'] = $hashTable.SyncRoot
        $templateBase['variables'] = $variables
        $tempTemplate = ConvertTo-Json -InputObject $templateBase -Depth 100
        Out-File -InputObject $tempTemplate -FilePath "$tempPath\tempfile.json"
        $file = Get-ChildItem -Path "$tempPath\tempfile.json"

        if ($file) {
            $BicepObject = ConvertTo-BicepNetFile -Path $file.FullName
            foreach ($BicepFile in $BicepObject.Keys) {
                $bicepData = $BicepObject[$BicepFile]
            }
            $bicepOutput = $bicepData.Replace("var temp = ", "")
            if ($ToClipboard.IsPresent) {                
                Set-Clipboard -Value $bicepOutput
                Write-Host "Bicep object saved to clipboard"
            }
            else {
                Write-Output $bicepOutput
            }
        }
        Remove-Item $file
    }
}
