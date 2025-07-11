BeforeAll {
  Import-Module -FullyQualifiedName "$PSScriptRoot\..\output\Bicep" -ErrorAction Stop
}

Describe 'Get-BicepConfig tests' {
    BeforeAll {
        $ScriptDirectory = Split-Path -Path $PSCommandPath -Parent
        $null = New-Item -ItemType 'Directory' -Path 'TestDrive:\supportFiles' -ErrorAction 'Ignore'
        Copy-Item "$ScriptDirectory\supportFiles\*" -Destination 'TestDrive:\supportFiles'
        Copy-Item "$ScriptDirectory\supportFiles\workingBicep.bicep" -Destination 'TestDrive:\'
    }

    Context 'Parameters' {
        It 'Should have parameter Path' {
                (Get-Command Get-BicepConfig).Parameters.Keys | Should -Contain 'Path'
        }
        It 'Should have parameter Local' {
                (Get-Command Get-BicepConfig).Parameters.Keys | Should -Contain 'Local'
        }
        It 'Should have parameter Merged' {
                (Get-Command Get-BicepConfig).Parameters.Keys | Should -Contain 'Merged'
        }
        It 'Should have parameter Default' {
                (Get-Command Get-BicepConfig).Parameters.Keys | Should -Contain 'Default'
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
                  "AzureChinaCloud": {
                    "resourceManagerEndpoint": "https://management.chinacloudapi.cn",
                    "activeDirectoryAuthority": "https://login.chinacloudapi.cn"
                  },
                  "AzureCloud": {
                    "resourceManagerEndpoint": "https://management.azure.com",
                    "activeDirectoryAuthority": "https://login.microsoftonline.com"
                  },
                  "AzureUSGovernment": {
                    "resourceManagerEndpoint": "https://management.usgovcloudapi.net",
                    "activeDirectoryAuthority": "https://login.microsoftonline.us"
                  }
                },
                "credentialPrecedence": [
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
              "implicitExtensions": [
                "az"
              ],
              "analyzers": {
                "core": {
                  "verbose": false,
                  "enabled": true,
                  "rules": {
                    "no-hardcoded-env-urls": {
                      "level": "warning",
                      "disallowedhosts": [
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
              },
              "experimentalFeaturesEnabled": {
                "symbolicNameCodegen": false,
                "extendableParamFiles": false,
                "resourceTypedParamsAndOutputs": false,
                "sourceMapping": false,
                "legacyFormatter": false,
                "testFramework": false,
                "assertions": false,
                "waitAndRetry": false,
                "localDeploy": false,
                "resourceInfoCodegen": false,
                "moduleExtensionConfigs": false,
                "desiredStateConfiguration": false,
                "externalInputFunction": false,
                "onlyIfNotExists": false,
                "moduleIdentity": false
              },
              "formatting": {
                "indentKind": "Space",
                "newlineKind": "LF",
                "insertFinalNewline": true,
                "indentSize": 2,
                "width": 120
              }
            }
'@
        }

        It 'Returns default when used without parameters' {
            $defaultConfig = Get-BicepConfig
            $defaultConfig.Path | Should -Be 'Default'
        }

        It 'Returns merged config when used with only Path' {
            # Excluding the extensions property as it is output using different sorting order each time
            $config = Get-BicepConfig -Path "$TestDrive/supportFiles/workingBicep.bicep"
            $mergedConfigTest = ConvertFrom-Json -InputObject $mergedConfig | 
              Select-Object -ExcludeProperty extensions | ConvertTo-Json -Depth 10
            $ConfigJson = ConvertFrom-Json -InputObject $config.Config | 
              Select-Object -ExcludeProperty extensions | ConvertTo-Json -Depth 10
            $ConfigJson | Should -BeExactly $mergedConfigTest
        }

        It 'Returns default config when used with only Path and no local config exists' {
            $config = Get-BicepConfig -Path "$TestDrive/workingBicep.bicep"
            $config.Path | Should -Be 'Default'
        }

        It 'Get default config' {
            $defaultConfig = Get-BicepConfig -Default
            $defaultConfig.Path | Should -Be 'Default'
        }

        It 'Get merged bicepconfig' {
            # Excluding the extensions property as it is output using different sorting order each time
            $config = Get-BicepConfig -Path "$TestDrive/supportFiles/workingBicep.bicep" -Merged
            $mergedConfigTest = ConvertFrom-Json -InputObject $mergedConfig | 
              Select-Object -ExcludeProperty extensions | ConvertTo-Json -Depth 10
            $ConfigJson = ConvertFrom-Json -InputObject $config.Config | 
              Select-Object -ExcludeProperty extensions | ConvertTo-Json -Depth 10
            $ConfigJson | Should -BeExactly $mergedConfigTest
        }

        It 'Returns default config when used with Path and Merged and no local config exists' {
            $config = Get-BicepConfig -Path "$TestDrive/workingBicep.bicep" -Merged
            $config.Path | Should -Be 'Default'
        }


        It 'Get local bicepconfig' {
            $config = Get-BicepConfig -Path "$TestDrive/supportFiles/workingBicep.bicep" -Local
            $localConfigTest = ConvertFrom-Json -InputObject $localConfig | ConvertTo-Json -Depth 10
            $ConfigJson = ConvertFrom-Json -InputObject $config.Config | ConvertTo-Json -Depth 10
            $ConfigJson | Should -BeExactly $localConfigTest
        }

        It 'Throws an error when using parameters Path and Default' {
            {Get-BicepConfig -Path "$TestDrive/supportFiles/workingBicep.bicep" -Default} | Should -Throw
        }

        AfterAll {
            # Bicep doesnt seem to properly release the config file, let's wait for it.
            $configFileLocked = $true
            $configFilePath = Join-Path $TestDrive 'supportFiles/bicepconfig.json'
            while($configFileLocked) {
                try {
                    $configFile = [System.IO.File]::Open($configFilePath, 'Open', 'Read')
                    $configFile.Close()
                    $configFile.Dispose()
                    $configFileLocked = $false
                }
                catch {
                    Write-Warning "Bicepconfig file locked, waiting for it to be released."
                    Start-Sleep -Seconds 1
                    continue
                }
            }
        }
    }
}
