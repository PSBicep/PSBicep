function Get-BicepRestoreTypeName {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $Type
    )
    
    $TypeName = 'BicepRestoreParameters{0}' -f $Type
    try {
        $TypeObject = $TypeName -as [type]
    }
    catch {
        throw "Type [$TypeName] not found."
    }
    
    if (-not ($TypeObject.IsSubclassOf([BicepRestoreParametersBase]))) {
        throw "Type [$TypeName] does not inherit from [BicepRestoreParametersBase]"
    }

    return $TypeName
}