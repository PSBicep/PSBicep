function ValidateAzureToken {
    param (
        [Parameter(Mandatory)]
        [AllowNull()]
        $Token,

        [Parameter()]
        $Resource = 'https://management.azure.com'
    )
    return (
        $null -ne $Token -and
        $Token.ExpiresOn -ge [System.DateTimeOffset]::Now.AddMinutes(15) -and
        $Token.Claims['aud'] -eq $Resource
    )
}