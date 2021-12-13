BeforeAll {
    $ScriptDirectory = Split-Path -Path $PSCommandPath -Parent
    Import-Module -FullyQualifiedName "$ScriptDirectory\..\Source\Bicep.psd1" -ErrorAction Stop

    $ScriptDirectory = Split-Path -Path $PSCommandPath -Parent
    Copy-Item "$ScriptDirectory\supportFiles\*" -Destination TestDrive:\
}

Describe 'Publish-Bicep' {
    BeforeEach {
        Mock -CommandName TestModuleVersion -ModuleName Bicep -Verifiable -MockWith { }
        Mock -CommandName Test-BicepFile -ModuleName Bicep -Verifiable -MockWith {
            Return $true
        }
    }
    
    Context 'Parameter validation' {
        $GoodParamTestCases = @(
            @{
                Pattern = 'br:contosoregistry.azurecr.io/bicep/modules/core/storage:v1'
            },
            @{
                Pattern = 'br:contosoregistry.azurecr.io/modules/storage:v1'
            },
            @{
                Pattern = 'br:contosoregistry.azurecr.io/storage:v5'
            },
            @{
                Pattern = 'br/ContosoRegistry:bicep/modules/core/storage:v1'
            },
            @{
                Pattern = 'br/ContosoRegistry:bicep/modules/storage:v1'
            },
            @{
                Pattern = 'br/ContosoRegistry:storage:v5'
            }
        )
        $BadParamTestCases = @(
            @{
                Pattern = 'ab/ContosoRegistry:storage:v5'
            },
            @{
                Pattern = 'br/ContosoRegistry.storage'
            }
        )
        
        BeforeEach {
            function Publish-BicepNetFile {}
            Mock -CommandName Publish-BicepNetFile -MockWith {
                Return $true
            }
        }

        It 'Validation of registry <Pattern> should work' -TestCases $GoodParamTestCases {
            {Publish-Bicep -Path 'TestDrive:\workingBicep.bicep' -Target $Pattern} | Should -Not -Throw
        }
        It 'Validation of registry <Pattern> should not work' -TestCases $BadParamTestCases {
            {Publish-Bicep -Path 'TestDrive:\workingBicep.bicep' -Target $Pattern} | Should -Throw
        }
    }

    Context 'Validate publish data' {
        BeforeEach {
            function Publish-BicepNetFile($Path, $Target) {throw}
            Mock -CommandName Publish-BicepNetFile -MockWith {
                [PSCustomObject]@{
                    Path = $Path
                    Target = $Target
                }
            } 
        }

        It 'Should call Publish-BicepNetFile' {
            $r = Publish-Bicep -Path 'TestDrive:\workingBicep.bicep' -Target 'br:contosoregistry.azurecr.io/bicep/modules/core/storage:v1'
            Should -Invoke Publish-BicepNetFile -Times 1
        }
        It 'Path should be same as input' {
            $ItemName = Get-Item 'TestDrive:\workingBicep.bicep'
            $r = Publish-Bicep -Path $ItemName.FullName -Target 'br:contosoregistry.azurecr.io/bicep/modules/core/storage:v1'
            $r.Path | Should -Be $ItemName.FullName
        }
        It 'Target should be same as input' {
            $TargetName = 'br:contosoregistry.azurecr.io/bicep/modules/core/storage:v1'
            $r = Publish-Bicep -Path 'TestDrive:\workingBicep.bicep' -Target $TargetName
            $r.Target | Should -Be $TargetName
        }
    }
}

