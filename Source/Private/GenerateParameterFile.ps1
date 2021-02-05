function GenerateParameterFile {
    [CmdletBinding(DefaultParameterSetName='FromFile')]
    param (
        [Parameter(ParameterSetName = 'FromFile')]
        [object]$File,
        [parameter(ParameterSetName = 'FromContent')]
        [string]$Content
    )

    if ($PSCmdlet.ParameterSetName -eq 'FromFile') {
        $fileName = $file.Name -replace ".bicep", ""
        $ARMTemplate = Get-Content "$($file.DirectoryName)\$filename.json" -Raw | ConvertFrom-Json
    }
    elseif ($PSCmdlet.ParameterSetName -eq 'FromContent') {
        $ARMTemplate = $Content | ConvertFrom-Json
    }
    
    $parameterBase = [ordered]@{
        '$schema'        = 'https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#'
        'contentVersion' = '1.0.0.0'
    }
    $parameterNames = $ARMTemplate.Parameters.psobject.Properties.Name
    $parameters = [ordered]@{}
    foreach ($parameterName in $parameterNames) {
        $ParameterObject = $ARMTemplate.Parameters.$ParameterName
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
        }
        else {
            $defaultValue = $ParameterObject.defaultValue
        }
        $parameters[$parameterName] = @{                                
            value = $defaultValue
        }                       
    }
    $parameterBase['parameters'] = $parameters
    ConvertTo-Json -InputObject $parameterBase -Depth 100 | Out-File "$($file.DirectoryName)\$filename.parameters.json"
}