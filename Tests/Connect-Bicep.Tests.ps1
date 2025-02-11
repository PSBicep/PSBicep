BeforeAll {
    Import-Module -FullyQualifiedName "$PSScriptRoot\..\output\Bicep" -ErrorAction Stop
    Copy-Item "$PSScriptRoot\supportFiles\*" -Destination TestDrive:\
}

Describe 'Connect-Bicep tests' {
    InModuleScope Bicep {
        BeforeAll {
            Mock Get-AzToken -ModuleName 'Bicep' {
                [pscustomobject]@{
                    Token             = 'FakeToken'
                    ExpiresOn         = [DateTimeOffset]::Now.AddHours(1)
                    PSBoundParameters = $PesterBoundParameters # Magic Pester variable: https://pester.dev/docs/usage/mocking#pesterboundparameters
                }
            } -Verifiable

            # Example tenant GUID, not a real tenant
            $TenantId = '23370773-7acc-4b47-9003-7ff5d6bd53df'
            # Real ClientID - but doesn't matter
            $DefaultClientId = '1950a258-227b-4e31-a9cf-717495945fc2'
            $FakeClientId = '77777777-227b-4e31-a9cf-717495945fc2'
        }
        Context 'ManagedIdentity tests' {
            It 'Should connect using Managed Identity with tenantid' {
                
                Connect-Bicep -ManagedIdentity -Tenant $TenantId

                Should -Invoke -CommandName Get-AzToken -Times 1
                $Script:Token.PSBoundParameters.ClientId | Should -Be $DefaultClientId
                $Script:Token.PSBoundParameters.TenantId | Should -Be $TenantId
                $Script:Token.PSBoundParameters.ClientCertificate | Should -BeNullOrEmpty
                $Script:Token.PSBoundParameters.ClientCertificatePath | Should -BeNullOrEmpty
                $Script:Token.PSBoundParameters.Interactive | Should -BeNullOrEmpty
                $Script:Token.PSBoundParameters.ManagedIdentity.IsPresent | Should -Be $true
            }
            It 'Should connect using Managed Identity without tenantid' {
                
                Connect-Bicep -ManagedIdentity

                Should -Invoke -CommandName Get-AzToken -Times 1
                $Script:Token.PSBoundParameters.ClientId | Should -Be $DefaultClientId
                $Script:Token.PSBoundParameters.TenantId | Should -BeNullOrEmpty
                $Script:Token.PSBoundParameters.ClientCertificate | Should -BeNullOrEmpty
                $Script:Token.PSBoundParameters.ClientCertificatePath | Should -BeNullOrEmpty
                $Script:Token.PSBoundParameters.Interactive | Should -BeNullOrEmpty
                $Script:Token.PSBoundParameters.ManagedIdentity.IsPresent | Should -Be $true
            }
        }
        Context 'Interactive tests' {
            It 'Should connect Interactively with tenantid' {
                Connect-Bicep -Tenant $TenantId

                Should -Invoke -CommandName Get-AzToken -Times 1
                $Script:Token.PSBoundParameters.ClientId | Should -Be $DefaultClientId
                $Script:Token.PSBoundParameters.TenantId | Should -Be $TenantId
                $Script:Token.PSBoundParameters.ClientCertificate | Should -BeNullOrEmpty
                $Script:Token.PSBoundParameters.ClientCertificatePath | Should -BeNullOrEmpty
                $Script:Token.PSBoundParameters.Interactive.IsPresent | Should -Be $true
                $Script:Token.PSBoundParameters.ManagedIdentity | Should -BeNullOrEmpty
            }
            It 'Should connect Interactively without tenantid' {
                Connect-Bicep

                Should -Invoke -CommandName Get-AzToken -Times 1
                $Script:Token.PSBoundParameters.ClientId | Should -Be $DefaultClientId
                $Script:Token.PSBoundParameters.TenantId | Should -BeNullOrEmpty
                $Script:Token.PSBoundParameters.ClientCertificate | Should -BeNullOrEmpty
                $Script:Token.PSBoundParameters.ClientCertificatePath | Should -BeNullOrEmpty
                $Script:Token.PSBoundParameters.Interactive.IsPresent | Should -Be $true
                $Script:Token.PSBoundParameters.ManagedIdentity | Should -BeNullOrEmpty
            }
        }
        Context 'Certificate tests' {
            BeforeAll {
                Mock Get-Item -ModuleName Bicep { 
                    if($Path -like 'Cert:*') {
                        [System.Security.Cryptography.X509Certificates.X509Certificate2]::new()
                    } else {
                        return $Path
                    }
                }
            }
            It 'Should connect using Certificate as path' {
                $CertificatePath = 'TestDrive:\test.pfx'
                Connect-Bicep -Tenant $TenantId -CertificatePath $CertificatePath -ClientId $FakeClientId

                Should -Invoke -CommandName Get-AzToken -Times 1
                $Script:Token.PSBoundParameters.ClientId | Should -Be $FakeClientId
                $Script:Token.PSBoundParameters.TenantId | Should -Be $TenantId
                $Script:Token.PSBoundParameters.ClientCertificate | Should -BeNullOrEmpty
                $Script:Token.PSBoundParameters.ClientCertificatePath | Should -Be $CertificatePath
                $Script:Token.PSBoundParameters.Interactive | Should -BeNullOrEmpty
                $Script:Token.PSBoundParameters.ManagedIdentity | Should -BeNullOrEmpty
            }
            It 'Should connect using Certificate as path' {
                $CertificatePath = 'Cert:\CurrentUser\My\12345678901234567890123456789012'
                Connect-Bicep -Tenant $TenantId -CertificatePath $CertificatePath -ClientId $FakeClientId

                Should -Invoke -CommandName Get-AzToken -Times 1
                $Script:Token.PSBoundParameters.ClientId | Should -Be $FakeClientId
                $Script:Token.PSBoundParameters.TenantId | Should -Be $TenantId
                $Script:Token.PSBoundParameters.ClientCertificate | Should -BeOfType 'System.Security.Cryptography.X509Certificates.X509Certificate2'
                $Script:Token.PSBoundParameters.ClientCertificatePath | Should -BeNullOrEmpty
                $Script:Token.PSBoundParameters.Interactive | Should -BeNullOrEmpty
                $Script:Token.PSBoundParameters.ManagedIdentity | Should -BeNullOrEmpty
            }
        }
    }
}
