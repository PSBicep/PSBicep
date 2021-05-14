function GenerateParameterFile {
    [CmdletBinding(DefaultParameterSetName = 'FromFile',
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
        [string]$DestinationPath,

        [Parameter(ParameterSetName = 'FromFile')]
        [Parameter(ParameterSetName = 'FromContent')]
        [string]$Parameters
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
    $parameterHash = [ordered]@{}
    foreach ($parameterName in $parameterNames) {
        $ParameterObject = $ARMTemplate.Parameters.$ParameterName
        if (($Parameters -eq "Required" -and $null -eq $ParameterObject.defaultValue) -or ($Parameters -eq "All")) {
        if ($null -eq $ParameterObject.defaultValue) {                               
            if ($ParameterObject.type -eq 'Array') {
                $defaultValue = @()
            }
            elseif ($ParameterObject.type -eq 'Object') {
                $defaultValue = @{}
            }
            elseif ($ParameterObject.type -eq 'int') {
                $defaultValue = 0
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
            $parameterHash[$parameterName] = @{                                
                value = $defaultValue
            }
        }                       
    }
    $parameterBase['parameters'] = $parameterHash
    $ConvertedToJson = ConvertTo-Json -InputObject $parameterBase -Depth 100
    
    switch ($PSCmdlet.ParameterSetName) {
        'FromFile' {
            Out-File -InputObject $ConvertedToJson -FilePath "$($file.DirectoryName)\$filename.parameters.json" -WhatIf:$WhatIfPreference
        }
        'FromContent' {
            Out-File -InputObject $ConvertedToJson -FilePath $DestinationPath -WhatIf:$WhatIfPreference
        }
        Default {
            Write-Error "Unable to generate parameter file. Unknown parameter set: $($PSCmdlet.ParameterSetName)"
        }
    }
}