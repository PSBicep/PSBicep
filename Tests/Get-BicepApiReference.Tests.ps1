$ScriptDirectory = Split-Path -Path $PSCommandPath -Parent
Import-Module -FullyQualifiedName "$ScriptDirectory\..\Source\Bicep.psd1"

Describe "Get-BicepApiReference" {
    InModuleScope Bicep {
        BeforeAll {
            Mock Invoke-WebRequest {}
            Mock Start-Process {
                $FilePath
            }
        }

        Context 'Exceptions' {
            BeforeAll {
                Mock Invoke-WebRequest {
                    throw "error"
                }
            }

            It 'Throws expected error when url is not found' {
                $params = @{
                    ResourceProvider = 'Microsoft.Aad'
                    Resource         = 'domainServices' 
                    Child            = 'ouContainer'
                }
                { Get-BicepApiReference @params -ErrorAction Stop } | Should -Throw -ExpectedMessage 'No documentation found.*'
                
            }
        }

        Context 'URL is built correctly' {
            
            $testcases = @(
                @{
                    ParameterSet = 'ResourceProvider with Child'
                    Splat        = @{
                        ResourceProvider = 'Microsoft.Aad'
                        Resource         = 'domainServices' 
                        Child            = 'ouContainer'
                    }
                    Result       = 'https://docs.microsoft.com/en-us/azure/templates/Microsoft.Aad/domainServices/ouContainer?tabs=bicep'
                }
                @{
                    ParameterSet = 'ResourceProvider with APIVersion'
                    Splat        = @{
                        ResourceProvider = 'Microsoft.Aad'
                        Resource         = 'domainServices'
                        APIVersion       = '2021-03-01'
                    }
                    Result       = 'https://docs.microsoft.com/en-us/azure/templates/Microsoft.Aad/2021-03-01/domainServices?tabs=bicep'
                }
                @{
                    ParameterSet = 'ResourceProvider'
                    Splat        = @{
                        ResourceProvider = 'Microsoft.Aad'
                        Resource         = 'domainServices' 
                    }
                    Result       = 'https://docs.microsoft.com/en-us/azure/templates/Microsoft.Aad/domainServices?tabs=bicep'
                }
                @{
                    ParameterSet = 'ResourceProvider with Child and APIVersion'
                    Splat        = @{
                        ResourceProvider = 'Microsoft.Aad'
                        Resource         = 'domainServices'
                        Child            = 'ouContainer'
                        APIVersion       = '2021-03-01'
                    }
                    Result       = 'https://docs.microsoft.com/en-us/azure/templates/Microsoft.Aad/2021-03-01/domainServices/ouContainer?tabs=bicep'
                }
            )

            It "should create a valid URL using parameters <Parameters>" -TestCases $testcases {
                Get-BicepApiReference @Splat | Should -Be $Result
            }

            It 'should create a correctly formatted URL' {
                $params = @{
                    ResourceProvider = 'Microsoft.Aad'
                    Resource         = 'domainServices' 
                    Child            = 'ouContainer'
                }
                $url = Get-BicepApiReference @params
                $url | Should -Match '^https://docs.microsoft.com/en-us/azure/templates/Microsoft\.([a-zA-Z]+/)+[a-zA-Z]+\?tabs=bicep$'
            }
        }

        Context 'Failed validations' {
            $failcases = @(
                @{
                    Parameters = 'ResourceProvider'
                    Splat      = @{
                        ResourceProvider = 'NotAResourceProvider'
                        Resource         = 'domainServices' 
                        Child            = 'ouContainer'
                    }
                    Result     = "Cannot validate argument on parameter 'ResourceProvider'*"
                }
                @{
                    Parameters = 'Resource'
                    Splat      = @{
                        ResourceProvider = 'Microsoft.Aad'
                        Resource         = 'NotAResource' 
                    }
                    Result     = "Cannot validate argument on parameter 'Resource'*"
                }
                @{
                    Parameters = 'Child'
                    Splat      = @{
                        ResourceProvider = 'Microsoft.Aad'
                        Resource         = 'domainServices'
                        Child            = 'NotAChild'
                        APIVersion       = '2021-03-01'
                    }
                    Result     = "Cannot validate argument on parameter 'Child'*"
                }
                @{
                    Parameters = 'APIVersion'
                    Splat      = @{
                        ResourceProvider = 'Microsoft.Aad'
                        Resource         = 'domainServices'
                        Child            = 'ouContainer'
                        APIVersion       = '1600-01-01'
                    }
                    Result     = "Cannot validate argument on parameter 'APIVersion'*"
                }
            )

            It "Should throw expected error message with parameter <Parameters>" -TestCases $failcases {
                { Get-BicepApiReference @Splat } | Should -Throw -ExpectedMessage $Result
            }
        }
    }
}
