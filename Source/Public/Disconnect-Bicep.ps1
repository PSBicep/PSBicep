function Disconnect-AzResourceGraph {
    [CmdletBinding()]
    param ()

    $script:TokenSplat = @{}
    $script:TokenSource = 'Global'
    $script:Token = $null
    $script:CertificatePath = $null
}