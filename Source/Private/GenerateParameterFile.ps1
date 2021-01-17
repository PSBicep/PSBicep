function GenerateParameterFile {
   [CmdletBinding()]
   param (
        [object]$File
   )    
    $fileName = $file.Name -replace ".bicep", ""
    $armTemplate = Get-Content "$($file.DirectoryName)\$filename.json" -Raw | ConvertFrom-Json
    $parameterBase = [ordered]@{
        '$schema'        = 'https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#'
        'contentVersion' = '1.0.0.0'
    }
    $parameterNames = $armTemplate.Parameters.psobject.Properties.Name
    $parameters = [ordered]@{}
    foreach ($parameterName in $parameterNames) {
        $ParameterObject = $ArmTemplate.Parameters.$ParameterName
        if ($null -eq $ParameterObject.defaultValue) {                               
            if ($ParameterObject.type -eq 'Array') {
                $defaultValue = @()
            }
            elseif ($ParameterObject.type -eq 'Object') {
                $defaultValue = @{}
            }
            else {
                $defaultValue = ""
            }
        }
        elseif ($ParameterObject.defaultValue -like "*()*") {
            $defaultValue = ""
        } else {
            $defaultValue = $ParameterObject.defaultValue
        }
        $parameters[$parameterName] = @{                                
            value = $defaultValue
        }                       
    }
    $parameterBase['parameters'] = $parameters
    ConvertTo-Json -InputObject $parameterBase -Depth 100 | Out-File "$($file.DirectoryName)\$filename.parameters.json"
}