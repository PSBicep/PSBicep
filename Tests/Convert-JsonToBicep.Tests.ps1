BeforeAll {
    $ScriptDirectory = Split-Path -Path $PSCommandPath -Parent
    Import-Module -FullyQualifiedName (Join-Path $PSScriptRoot '..\Source\Bicep.psd1') -ErrorAction Stop

    Copy-Item "$ScriptDirectory\supportFiles\*" -Destination TestDrive:\
}

InModuleScope -ModuleName Bicep {
    Describe 'Convert-JsonToBicep tests' {

        Context 'Parameters' {
            It 'Should have parameter String' {
                (Get-Command Convert-JsonToBicep).Parameters.Keys | Should -Contain 'String'
            }
            It 'Should have parameter Path' {
                (Get-Command Convert-JsonToBicep).Parameters.Keys | Should -Contain 'Path'
            }
            It 'Should have parameter ToClipboard' {
                (Get-Command Convert-JsonToBicep).Parameters.Keys | Should -Contain 'ToClipboard'
            }
        }

        Context 'Converting JSON' {
            
            BeforeAll {
                $jsonString = @'
                {
                    "name": "rdp-rule",
                    "properties": {
                      "description": "Allow RDP",
                      "protocol": "Tcp",
                      "sourcePortRange": "*",
                      "destinationPortRange": "3389",
                      "sourceAddressPrefix": "Internet",
                      "destinationAddressPrefix": "*",
                      "access": "Allow",
                      "priority": 100,
                      "direction": "Inbound"
                    }
                  }
'@
            }
            
            It 'Should convert JSON string to bicep' {
                Convert-JsonToBicep -String $jsonString | Should -BeOfType System.String
            }

            It 'Should convert JSON from path to Bicep' {
                Convert-JsonToBicep -Path 'TestDrive:\nsgRule.json' | Should -BeOfType System.String
            }

            It 'Should write output' {
                $bicepData = Convert-JsonToBicep -Path 'TestDrive:\nsgRule.json'
                $bicepData | Should -Not -BeNullOrEmpty
            }

        }
    }
}