BeforeAll {
    Import-Module -FullyQualifiedName "$PSScriptRoot\..\output\Bicep" -ErrorAction Stop
    Copy-Item "$PSScriptRoot\supportFiles\*" -Destination TestDrive:\
}

Describe 'AssertAzureConnection tests' {
    InModuleScope Bicep {
        BeforeAll {
            Mock Get-AzToken -ModuleName 'Bicep' {
                [pscustomobject]@{
                    Token             = 'FakeToken'
                    ExpiresOn         = [DateTimeOffset]::Now
                    PSBoundParameters = $PesterBoundParameters # Magic Pester variable: https://pester.dev/docs/usage/mocking#pesterboundparameters
                }
            } -Verifiable

            # Example tenant GUID, not a real tenant
            $TenantId = '23370773-7acc-4b47-9003-7ff5d6bd53df'
        }
        Context 'Token tests' {
            It 'Should refresh token when expired or expiring' {
                $Script:Token = @{
                    Token     = 'FakeToken'
                    ExpiresOn = [DateTimeOffset]::Now
                    Claims    = @{ 'aud' = 'https://management.azure.com' }
                }
                AssertAzureConnection -TokenSplat @{'ClientId' = $DefaultClientId; 'TenantId' = $TenantId; Interactive = $true }

                Should -Invoke -CommandName Get-AzToken -Times 1

                $Script:Token.PSBoundParameters.ContainsKey('Interactive') | Should -Be $false
            }
     
            It 'Should not refresh valid token' {
                $Script:Token = @{
                    Token     = 'FakeToken'
                    ExpiresOn = [DateTimeOffset]::Now.AddHours(1)
                    Claims    = @{ 'aud' = 'https://management.azure.com' }
                }
                AssertAzureConnection -TokenSplat @{'ClientId' = $DefaultClientId; 'TenantId' = $TenantId; Interactive = $true }

                Should -Invoke -CommandName Get-AzToken -Times 0
            }
        }
    }
}
