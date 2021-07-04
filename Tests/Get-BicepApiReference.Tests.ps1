BeforeAll {
    $ScriptDirectory = Split-Path -Path $PSCommandPath -Parent
    Import-Module -FullyQualifiedName "$ScriptDirectory\..\Source\Bicep.psd1" -ErrorAction Stop
}

Describe "Get-BicepApiReference" {
    BeforeAll {
        Mock Invoke-WebRequest -ModuleName Bicep {}
        Mock Start-Process -ModuleName Bicep {
            $FilePath
        }
    }

    Context 'Checks for new module version' {
        It 'Calls TestModuleVersion only once' {
            InModuleScope Bicep {
                Mock TestModuleVersion {
                    $Script:ModuleVersionChecked = $true
                }
                $Script:ModuleVersionChecked = $false

                $null = Get-BicepApiReference -Type 'Microsoft.Network/virtualNetworks@2020-06-01'
                $null = Get-BicepApiReference -Type 'Microsoft.Network/virtualNetworks@2020-06-01'
                Should -Invoke TestModuleVersion -ModuleName Bicep -Exactly -Times 1
            }
        }
    }

    Context 'Exceptions' {
        BeforeAll {
            Mock Invoke-WebRequest -ModuleName Bicep {
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

    Context 'No parameters' {
        It "Opens template start page when no parameters are provided" {
            Get-BicepApiReference | Should -Be 'https://docs.microsoft.com/en-us/azure/templates'   
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

        It 'Should create a valid URL using parameter set "<ParameterSet>"' -TestCases $testcases {
            Get-BicepApiReference @Splat | Should -Be $Result
        }

        It 'Should create a correctly formatted URL' {
            $params = @{
                ResourceProvider = 'Microsoft.Aad'
                Resource         = 'domainServices'
                Child            = 'ouContainer'
            }
            $url = Get-BicepApiReference @params
            $url | Should -Match '^https://docs.microsoft.com/en-us/azure/templates/Microsoft\.([a-zA-Z]+/)+[a-zA-Z]+\?tabs=bicep$'
        }

        It 'Should create a correct URL when using Type parameter' {
            $Url = Get-BicepApiReference -Type 'Microsoft.Network/virtualNetworks/subnets@2020-06-01'
            $Url | Should -Be 'https://docs.microsoft.com/en-us/azure/templates/Microsoft.Network/2020-06-01/virtualNetworks/subnets?tabs=bicep'
        }

        It 'Should create a correct URL when using Type and Latest parameters' {
            $Url = Get-BicepApiReference -Type 'Microsoft.Network/virtualNetworks/subnets@2020-06-01' -Latest
            $Url | Should -Be 'https://docs.microsoft.com/en-us/azure/templates/Microsoft.Network/virtualNetworks/subnets?tabs=bicep'
        }

        It 'Should create a correct URL when using Type and Latest parameters without TypeChild' {
            $Url = Get-BicepApiReference -Type 'Microsoft.Network/virtualNetworks@2020-06-01' -Latest
            $Url | Should -Be 'https://docs.microsoft.com/en-us/azure/templates/Microsoft.Network/virtualNetworks?tabs=bicep'
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
