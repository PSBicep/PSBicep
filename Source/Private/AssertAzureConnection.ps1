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

    # If token doesn't exist, has expired, or is for another resource - get a new one
    if ($null -eq $script:Token -or 
        $script:Token.ExpiresOn -le [System.DateTimeOffset]::Now.AddMinutes(-15) -or 
        $script:Token.Claims['aud'] -ne $Resource
    ) {
        try {
            $TokenSplat['Resource'] = $Resource
            if ($CertificatePath) {
                $Certificate = Get-Item $CertificatePath
                
                # If platform is Windows, the Certificate is a cert object, otherwise a file 
                if ($Certificate -is [System.Security.Cryptography.X509Certificates.X509Certificate2]) {
                    $TokenSplat['ClientCertificate'] = Get-Item $CertificatePath
                }
                else {
                    $TokenSplat['ClientCertificatePath'] = $CertificatePath
                }
            }
            $script:Token = Get-AzToken @TokenSplat -ErrorAction 'Stop'
        } catch {
            throw 'Not connected to Azure. Please connect to Azure by running Connect-Bicep before running this command.'
        }
    }
}
