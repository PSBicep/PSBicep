BeforeAll {
    $ScriptDirectory = Split-Path -Path $PSCommandPath -Parent
    Import-Module -FullyQualifiedName "$ScriptDirectory\..\Source\Bicep.psd1" -ErrorAction Stop

    
}

Describe 'Get-BicepConfig tests' {
    BeforeAll {
        $ScriptDirectory = Split-Path -Path $PSCommandPath -Parent
        Copy-Item "$ScriptDirectory\supportFiles\*" -Destination TestDrive:\
    }

    Context 'Parameters' {
        It 'Should have parameter Path' {
                (Get-Command Get-BicepConfig).Parameters.Keys | Should -Contain 'Path'
        }
        It 'Should have parameter Scope' {
                (Get-Command Get-BicepConfig).Parameters.Keys | Should -Contain 'Scope'
        }
    }

    Context 'Get bicepconfig' {
            
        BeforeAll {
            $localConfig = @'
                    {
                        "analyzers": {
                            "core": {
                                "verbose": false,
                                "enabled": true,
                                "rules": {
                                    "no-unused-params": {
                                        "level": "off"
                                    }
                                }
                            }
                        }
                    }
'@
            $mergedConfig = @'
                {
                    "cloud": {
                        "currentProfile": "AzureCloud",
                        "profiles": {
                            "AzureCloud": {
                                "resourceManagerEndpoint": "https://management.azure.com",
                                "activeDirectoryAuthority": "https://login.microsoftonline.com"
                            },
                            "AzureChinaCloud": {
                                "resourceManagerEndpoint": "https://management.chinacloudapi.cn",
                                "activeDirectoryAuthority": "https://login.chinacloudapi.cn"
                            },
                            "AzureUSGovernment": {
                                "resourceManagerEndpoint": "https://management.usgovcloudapi.net",
                                "activeDirectoryAuthority": "https://login.microsoftonline.us"
                            }
                        },
                        "credentialPrecedence": [
                            "AzureCLI",
                            "AzurePowerShell"
                        ]
                    },
                    "moduleAliases": {
                        "ts": {},
                        "br": {
                            "public": {
                                "registry": "mcr.microsoft.com",
                                "modulePath": "bicep"
                            }
                        }
                    },
                    "analyzers": {
                        "core": {
                            "verbose": false,
                            "enabled": true,
                            "rules": {
                                "no-hardcoded-env-urls": {
                                    "level": "warning",
                                    "disallowedhosts": [
                                        "api.loganalytics.io",
                                        "asazure.windows.net",
                                        "azuredatalakeanalytics.net",
                                        "azuredatalakestore.net",
                                        "batch.core.windows.net",
                                        "core.windows.net",
                                        "database.windows.net",
                                        "datalake.azure.net",
                                        "gallery.azure.com",
                                        "graph.windows.net",
                                        "login.microsoftonline.com",
                                        "management.azure.com",
                                        "management.core.windows.net",
                                        "region.asazure.windows.net",
                                        "trafficmanager.net",
                                        "vault.azure.net"
                                    ],
                                    "excludedhosts": [
                                        "schema.management.azure.com"
                                    ]
                                },
                                "no-unused-params": {
                                    "level": "off"
                                }
                            }
                        }
                    }
                }       
'@
        }
            
        It 'Get default config' {
            $defaultConfig = Get-BicepConfig -Scope 'Default' 
            $defaultConfig.Path | Should -Be 'Default'
        }

        It 'Get merged bicepconfig' {
            $config = Get-BicepConfig -Path "$TestDrive\workingBicep.bicep" -Scope Merged
            $mergedConfigTest = ConvertFrom-Json -InputObject $mergedConfig | ConvertTo-Json -Depth 10
            $ConfigJson = ConvertFrom-Json -InputObject $config.Config | ConvertTo-Json -Depth 10
            $ConfigJson | Should -BeExactly $mergedConfigTest
        }

        It 'Get local bicepconfig' {
            $config = Get-BicepConfig -Path "$TestDrive\workingBicep.bicep" -Scope Local
            $localConfigTest = ConvertFrom-Json -InputObject $localConfig | ConvertTo-Json -Depth 10
            $ConfigJson = ConvertFrom-Json -InputObject $config.Config | ConvertTo-Json -Depth 10
            $ConfigJson | Should -BeExactly $localConfigTest
        }

    }
}
