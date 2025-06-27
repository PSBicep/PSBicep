function ValidateAzureToken {
    param (
        [Parameter(Mandatory)]
        [AllowNull()]
        $Token,

        [Parameter()]
        $Resource = 'https://management.azure.com',

        [Parameter()]
        $MinValid = 15
    )
    return (
        $null -ne $Token -and
        $Token.ExpiresOn.UtcDateTime -ge [System.DateTimeOffset]::Now.AddMinutes($MinValid).UtcDateTime -and
        (
            # Due to AzAuth not showing correct aud claim when using Interactive and TokenCache we check either aud or scope
            # https://github.com/PalmEmanuel/AzAuth/issues/137
            $Resource -eq $Token.Claims['aud'] -or
            $Token.Scopes -contains "$Resource/.default"
        )
    )
}