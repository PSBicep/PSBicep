function Connect-Bicep {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        "PSAvoidDefaultValueForMandatoryParameter",
        "ClientId",
        Justification = "Client Id is only mandatory for certain auth flows."
    )]
    [CmdletBinding(DefaultParameterSetName = 'Interactive')]
    param (
        [Parameter(ParameterSetName = 'ManagedIdentity')]
        [Parameter(ParameterSetName = 'Interactive')]
        [Parameter(Mandatory, ParameterSetName = 'Certificate')]
        [Parameter(Mandatory, ParameterSetName = 'ClientSecret')]
        [ValidateNotNullOrEmpty()]
        [string]$Tenant,

        [Parameter(ParameterSetName = 'ManagedIdentity')]
        [Parameter(ParameterSetName = 'Interactive')]
        [Parameter(Mandatory, ParameterSetName = 'Certificate')]
        [Parameter(Mandatory, ParameterSetName = 'ClientSecret')]
        [ValidateNotNullOrEmpty()]
        [string]$ClientId = '1950a258-227b-4e31-a9cf-717495945fc2', # Default Azure PowerShell ClientId

        [Parameter(Mandatory, ParameterSetName = 'Certificate')]
        [string]$CertificatePath,

        [Parameter(Mandatory, ParameterSetName = 'ClientSecret')]
        [string]$ClientSecret,

        [Parameter(Mandatory, ParameterSetName = 'ManagedIdentity')]
        [switch]$ManagedIdentity,

        [Parameter(ParameterSetName = 'ManagedIdentity')]
        [Parameter(ParameterSetName = 'Interactive')]
        [Parameter(ParameterSetName = 'Certificate')]
        [Parameter(ParameterSetName = 'ClientSecret')]
        $ManagementEndpoint = 'https://management.azure.com'
    )

    # Set up module-scoped variables for getting tokens
    $script:TokenSplat = @{}
    $script:CertificatePath = $null

    $script:TokenSplat['Resource'] = $ManagementEndpoint
    $script:TokenSplat['ClientId'] = $ClientId
    if ($PSBoundParameters.ContainsKey('Tenant')) {
        $script:TokenSplat['Tenant'] = $Tenant
    }
    if ($PSBoundParameters.ContainsKey('CertificatePath')) {
        $script:CertificatePath = $CertificatePath
        $Certificate = Get-Item $CertificatePath

        if ($Certificate -is [System.Security.Cryptography.X509Certificates.X509Certificate2]) {
            $script:TokenSplat['ClientCertificate'] = Get-Item $CertificatePath
        }
        else {
            $script:TokenSplat['ClientCertificatePath'] = $CertificatePath
        }
    }
    if ($PSBoundParameters.ContainsKey('ClientSecret')) {
        $script:TokenSplat['ClientSecret'] = $ClientSecret
    }
    if ($PSCmdlet.ParameterSetName -eq 'Interactive') {
        $script:TokenSplat['Interactive'] = $true
        $script:TokenSplat['TokenCache'] = 'PSBicep'
    }
    if ($ManagedIdentity.IsPresent) {
        $script:TokenSplat['ManagedIdentity'] = $true
    }

    $script:Token = Get-AzToken @script:TokenSplat
    # Save the source of the token to module scope for AssertAzureConnection to know how to refresh it
    $script:TokenSource = 'PSBicep'
    if ($script:TokenSplat['Interactive'] -eq $true) {
        $script:TokenSplat['UserName'] = $script:Token.Identity
    }
}