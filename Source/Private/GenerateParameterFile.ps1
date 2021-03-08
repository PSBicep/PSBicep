function GenerateParameterFile {
    [CmdletBinding(DefaultParameterSetName='FromFile',
                   SupportsShouldProcess)]
    param (
        [Parameter(Mandatory,
                   ParameterSetName = 'FromFile')]
        [object]$File,

        [Parameter(Mandatory,
                   ParameterSetName = 'FromContent')]
        [ValidateNotNullOrEmpty()]
        [string]$Content,

        [Parameter(Mandatory,
                   ParameterSetName = 'FromContent')]
        [ValidateNotNullOrEmpty()]
        [string]$DestinationPath
    )

    if ($PSCmdlet.ParameterSetName -eq 'FromFile') {
        $FileName = $File.Name -replace ".bicep", ""
        $ARMTemplate = Get-Content "$($File.DirectoryName)\$Filename.json" -Raw | ConvertFrom-Json
    }
    elseif ($PSCmdlet.ParameterSetName -eq 'FromContent') {
        $ARMTemplate = $Content | ConvertFrom-Json
    }
    
    $ParameterBase = [ordered]@{
        '$schema'        = 'https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#'
        'contentVersion' = '1.0.0.0'
    }
    $ParameterNames = $ARMTemplate.Parameters.psobject.Properties.Name
    $Parameters = [ordered]@{}
    foreach ($parameterName in $parameterNames) {
        $ParameterObject = $ARMTemplate.Parameters.$ParameterName
        if ($null -eq $ParameterObject.defaultValue) {                               
            if ($ParameterObject.type -eq 'Array') {
                $DefaultValue = @()
            }
            elseif ($ParameterObject.type -eq 'Object') {
                $DefaultValue = @{}
            }
            else {
                $DefaultValue = ""
            }
        }
        elseif ($ParameterObject.defaultValue -like "*()*") {
            $DefaultValue = ""
        }
        else {
            $DefaultValue = $ParameterObject.defaultValue
        }
        $Parameters[$ParameterName] = @{                                
            value = $defaultValue
        }                       
    }
    $ParameterBase['parameters'] = $Parameters
    $ConvertedToJson = ConvertTo-Json -InputObject $ParameterBase -Depth 100
    
    switch ($PSCmdlet.ParameterSetName) {
        'FromFile' {
            Out-File -InputObject $ConvertedToJson -FilePath "$($File.DirectoryName)\$Filename.parameters.json" -WhatIf:$WhatIfPreference
        }
        'FromContent' {
            Out-File -InputObject $ConvertedToJson -FilePath $DestinationPath -WhatIf:$WhatIfPreference
        }
        Default {
            Write-Error "Unable to generate parameter file. Unknown parameter set: $($PSCmdlet.ParameterSetName)"
        }
    }
}