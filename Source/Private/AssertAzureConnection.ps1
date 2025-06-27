function AssertAzureConnection {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [hashtable]$TokenSplat,

        [Parameter()]
        [PSBicep.Models.BicepConfigInfo]$BicepConfig,

        [Parameter()]
        [string]$Resource = 'https://management.azure.com'
    )
    if (ValidateAzureToken -Token $script:Token -Resource $Resource -MinValid 15) {
        # If the token is valid, we can use that it
        return
    }
    $LocalTokenSplat = $TokenSplat.Clone()
    $LocalTokenSplat['Resource'] = $Resource
    $NotConnectedErrorMessage = 'Not connected to Azure. Please connect to Azure by running Connect-Bicep before running this command.'

    # Connect-Bicep has not been run and we can try to get a token based on credential precedence.
    if ($script:TokenSource -ne 'PSBicep') {
        Write-Warning -Message 'No token found. Attempting to get a new token.'
        $CredentialPrecedence = $BicepConfig?.cloud.credentialPrecedence ?? @('AzurePowerShell')
        try {
            $NewToken = Get-AzToken @LocalTokenSplat -CredentialPrecedence $CredentialPrecedence -ErrorAction 'Stop'
            $script:Token = $NewToken # Only make assignment to script scope if no exception is thrown
            return
        }
        catch {
            Write-Error -Exception $_.Exception -Message $NotConnectedErrorMessage -ErrorAction 'Stop'
        }
    }

    #  Connect-Bicep has ben run but the token is not valid, let's try to refresh it.
    Write-Verbose -Message 'No valid token found. Attempting to refresh the token.'
    try {
        if ($LocalTokenSplat.ContainsKey('ClientCertificatePath')) {
            # If platform is Windows, the Certificate can be a cert object, then get the object
            $Certificate = Get-Item -Path $LocalTokenSplat.ClientCertificatePath

            if ($Certificate.GetType().FullName -eq 'System.Security.Cryptography.X509Certificates.X509Certificate2') {
                $LocalTokenSplat['ClientCertificate'] = $Certificate
                $LocalTokenSplat.Remove('ClientCertificatePath')
            }
        }
        # If we reach this point, we know that we have run Connect command and that the token is not valid.
        # We can therefore safely remove the Interactive parameter from the local LocalTokenSplat
        if ($LocalTokenSplat.ContainsKey('Interactive')) {
            $LocalTokenSplat.Remove('Interactive')
            $LocalTokenSplat.Remove('ClientId')
        }

        $NewToken = Get-AzToken @LocalTokenSplat -ErrorAction 'Stop'
        $script:Token = $NewToken # Only make assignment to script scope if no exception is thrown
    }
    catch {
        Write-Error -Exception $_.Exception -Message $NotConnectedErrorMessage -ErrorAction 'Stop'
    }

}
