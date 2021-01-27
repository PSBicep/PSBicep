function ConvertTo-BicepRestoreParameter {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$Resource,

        [string]$BasePath = $PWD.Path
    )
    
    process {
        $TypeName = Get-BicepRestoreTypeName -Type $Resource.Type

        $Provider = New-Object -TypeName $TypeName -ArgumentList $Resource, $BasePath
        return $Provider
    }
}