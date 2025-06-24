BeforeAll {
    Import-Module -FullyQualifiedName "$PSScriptRoot\..\output\Bicep" -ErrorAction Stop
    Copy-Item "$PSScriptRoot\supportFiles\*" -Destination TestDrive:\
}

Describe 'AssertAzureConnection tests' {
    InModuleScope Bicep {
        Context 'when valid token exists' {
            BeforeEach {
                Mock 'ValidateAzureToken' { return $true }
                Mock 'Get-AzToken' {}
            }
            It 'does not call Get-AzToken' {
                AssertAzureConnection -TokenSplat @{}
                Should -Invoke 'ValidateAzureToken' -Times 1 -Exactly
                Should -Invoke 'Get-AzToken' -Times 0 -Exactly
            }
        }

        Context 'when Token invalid and TokenSource not PSBicep' {
            BeforeEach {
                $script:Token = $null
                $script:TokenSource = 'Other'
                Mock ValidateAzureToken { return $false }
            }
            It 'Calls Get-AzToken and sets script:Token on success' {
                # Returning inbound parameters allows for easy validation of parameter usage
                Mock 'Get-AzToken' { 'ValidToken' }
                AssertAzureConnection -TokenSplat @{ClientId = 'Foo'} -Resource 'Bar'
                Should -Invoke 'Get-AzToken' -Times 1 -Exactly -ParameterFilter {
                    $ClientId -eq 'Foo' -and $Resource -eq 'Bar'
                }
                $script:Token | Should -Be 'ValidToken'
            }
            It 'Throws error when Get-AzToken fails' {
                Mock 'Get-AzToken' { throw 'fail' }
                { AssertAzureConnection -TokenSplat @{} } | Should -Throw
            }
        }

        Context 'when Token invalid and TokenSource is PSBicep' {
            BeforeEach {
                $script:Token = $null
                $script:TokenSource = 'PSBicep'
                Mock ValidateAzureToken { return $false }
            }
            It 'Refreshes token without interactive parameters' {
                Mock 'Get-AzToken' { return 'Refreshed' }
                AssertAzureConnection -TokenSplat @{Interactive=$true;ClientId='X'}
                Should -Invoke 'Get-AzToken' -Times 1 -Exactly -ParameterFilter {
                    $null -eq $Interactive
                }
                $script:Token | Should -Be 'Refreshed'
            }

            It 'Passes ClientCertificatePath to Get-AzToken as ClientCertificatePath' {
                Mock 'Get-AzToken' { return 'RefreshedWithCertificate' }
                Mock 'Get-Item' { 'PathAsString' }
                AssertAzureConnection -TokenSplat @{
                    ClientCertificatePath = 'Foo'
                    TenantId = 'MyTenantId'
                    ClientId = 'MyClientId'
                }
                Should -Invoke 'Get-AzToken' -Times 1 -Exactly -ParameterFilter {
                    $ClientCertificatePath -eq 'Foo' -and $null -eq $ClientCertificate
                }
                $script:Token | Should -Be 'RefreshedWithCertificate'
            }

            It 'Passes ClientCertificatePath to Get-AzToken as ClientCertificate' {
                Mock 'Get-AzToken' { return 'RefreshedWithCertificate' }
                Mock 'Get-Item' { New-MockObject -Type 'System.Security.Cryptography.X509Certificates.X509Certificate2' }
                AssertAzureConnection -TokenSplat @{
                    ClientCertificatePath = 'Foo'
                    TenantId = 'MyTenantId'
                    ClientId = 'MyClientId'
                }
                Should -Invoke 'Get-AzToken' -Times 1 -Exactly -ParameterFilter {
                    $null -eq $ClientCertificatePath -and $ClientCertificate.GetType().FullName -eq 'System.Security.Cryptography.X509Certificates.X509Certificate2'
                }
                $script:Token | Should -Be 'RefreshedWithCertificate'
            }

            It 'Passes ClientCertificatePath to Get-AzToken as ClientCertificatePath' {
                Mock 'Get-AzToken' { return 'RefreshedWithCertificate' }
                Mock 'Get-Item' { New-MockObject -Type 'System.IO.FileInfo' }
                AssertAzureConnection -TokenSplat @{
                    ClientCertificatePath = 'Foo'
                    TenantId = 'MyTenantId'
                    ClientId = 'MyClientId'
                }
                Should -Invoke 'Get-AzToken' -Times 1 -Exactly -ParameterFilter {
                    $ClientCertificatePath -eq 'Foo' -and $null -eq $ClientCertificate
                }
                $script:Token | Should -Be 'RefreshedWithCertificate'
            }
            It 'Throws error when Get-AzToken fails' {
                Mock 'Get-AzToken' { throw 'fail' }
                Mock 'Get-Item' { New-MockObject -Type 'System.IO.FileInfo' }
                {
                    AssertAzureConnection -TokenSplat @{
                        ClientCertificatePath = 'Foo'
                        TenantId = 'MyTenantId'
                        ClientId = 'MyClientId'
                    }
                } | Should -Throw
            }
        }
    }
}
