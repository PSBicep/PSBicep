function AssertAzureConnection {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [hashtable]$TokenSplat,

        [Parameter()]
        [string]$CertificatePath,

        [Parameter()]
        [PSBicep.Models.BicepConfigInfo]$BicepConfig,

        [Parameter()]
        [string]$Resource = 'https://management.azure.com'
    )
    $LocalTokenSplat = $TokenSplat.Clone()
    $LocalTokenSplat['Resource'] = $Resource
    $NotConnectedErrorMessage = 'Not connected to Azure. Please connect to Azure by running Connect-Bicep before running this command.'

    # Connect-Bicep has not been run and we can try to get a token based on credential precedence.
    if ($script:TokenSource -ne 'PSBicep' -and $null -ne $BicepConfig) {
        try {
            $NewToken = Get-AzToken @LocalTokenSplat -CredentialPrecedence $BicepConfig.cloud.credentialPrecedence -ErrorAction 'Stop'
            $script:Token = $NewToken # Only make assignment to script scope if no exception is thrown
            return
        }
        catch {
            Write-Error -Exception $_.Exception -Message $NotConnectedErrorMessage -ErrorAction 'Stop'
        } 
    }
    
    #  If token is null, about to expire or has wrong resource/audience, try to refresh it
    if (-not (ValidateAzureToken -Token $script:Token -Resource $Resource)) {
        try {
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
            if ($LocalTokenSplat.ContainsKey('Interactive')) {
                $LocalTokenSplat.Remove('Interactive')
            }
            if ($LocalTokenSplat.ContainsKey('ClientId')) {
                $LocalTokenSplat.Remove('ClientId')
            }
            $NewToken = Get-AzToken @LocalTokenSplat -ErrorAction 'Stop'
            $script:Token = $NewToken # Only make assignment to script scope if no exception is thrown
        }
        catch {
            Write-Error -Exception $_.Exception -Message $NotConnectedErrorMessage -ErrorAction 'Stop'
        }
    }
}
