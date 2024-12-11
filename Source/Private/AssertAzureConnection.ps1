function AssertAzureConnection {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [hashtable]$TokenSplat,

        [Parameter()]
        [string]$CertificatePath,

        [Parameter()]
        [string]$Resource = 'https://management.azure.com'
    )
    $LocalTokenSplat = $TokenSplat.Clone()
    $NotConnectedErrorMessage = 'Not connected to Azure. Please connect to Azure by running Connect-Bicep before running this command.'
    if(-not $LocalTokenSplat.ContainsKey('ClientId')) {
        throw $NotConnectedErrorMessage
    }
    # If token doesn't exist, has expired, or is for another resource - get a new one
    if ($null -eq $script:Token -or 
        $script:Token.ExpiresOn -le [System.DateTimeOffset]::Now.AddMinutes(15) -or 
        $script:Token.Claims['aud'] -ne $Resource
    ) {
        try {
            $LocalTokenSplat['Resource'] = $Resource
            if ($CertificatePath) {
                $Certificate = Get-Item $CertificatePath
                
                # If platform is Windows, the Certificate is a cert object, otherwise a file 
                if ($Certificate -is [System.Security.Cryptography.X509Certificates.X509Certificate2]) {
                    $LocalTokenSplat['ClientCertificate'] = Get-Item $CertificatePath
                }
                else {
                    $LocalTokenSplat['ClientCertificatePath'] = $CertificatePath
                }
            }
            # If we reach this point, we know that we have run Connect-Bicep
            # We can therefore safely remove parameters from the local LocalTokenSplat
            # The non-interative token we get here should only be session-local from the previous auth
            if($LocalTokenSplat.ContainsKey('Interactive')) {
                $LocalTokenSplat.Remove('Interactive')
            }
            if($LocalTokenSplat.ContainsKey('ClientId')) {
                $LocalTokenSplat.Remove('ClientId')
            }
            $script:Token = Get-AzToken @LocalTokenSplat -ErrorAction 'Stop'
        } catch {
            Write-Error -Exception $_.Exception -Message $NotConnectedErrorMessage -ErrorAction 'Stop'
        }
    }
}
