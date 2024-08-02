BeforeAll {
    Import-Module -FullyQualifiedName "$PSScriptRoot\..\output\Bicep" -ErrorAction Stop
    Copy-Item "$PSScriptRoot\supportFiles\*" -Destination TestDrive:\
}

Describe 'Publish-Bicep' {
    BeforeEach {
        Mock -CommandName TestModuleVersion -ModuleName Bicep -Verifiable -MockWith { }
        Mock -CommandName Test-BicepFile -ModuleName Bicep -Verifiable -MockWith {
            Return $true
        }
    }
    
    Context 'Parameter validation' {
        InModuleScope Bicep { # Mocking of Publish-BicepFile is not working so we need to use an alias and 'InModuleScope'

            $GoodParamTestCases = @( 
                @{
                    Pattern = 'br:contosoregistry.azurecr.io/bicep/modules/core/storage:v1'
                },
                @{
                    Pattern = 'br:contosoregistry.azurecr.io/bicep/modules/core-with_dashes/storage:v1'
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
                    Pattern = 'br/ContosoRegistry:bicep/modules/core-with_dashes/storage:v1'
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
                },
                @{
                    Pattern = 'br/myModules/path/storage:v33'
                }
            )

            It 'Validation of registry <Pattern> should work' -Foreach $GoodParamTestCases {
                function Publish-BicepFileFake { }
                Mock Publish-BicepFileFake -Verifiable { 
                    return @{ Path = $Path; Target = $Target }
                }
                Set-Alias Publish-BicepFile Publish-BicepFileFake
                $r = Publish-Bicep -Path 'TestDrive:\workingBicep.bicep' -Target $Pattern
                Should -Invoke -CommandName Publish-BicepFileFake -Times 1
                $r.Path | Should -Be 'TestDrive:\workingBicep.bicep'
                $r.Target | Should -Be $Pattern
            }
            
            It 'Validation of registry <Pattern> should NOT work' -TestCases $BadParamTestCases {
                function Publish-BicepFileFake { }
                Mock Publish-BicepFileFake -Verifiable { }
                Set-Alias Publish-BicepFile Publish-BicepFileFake
                {$null = Publish-Bicep -Path 'TestDrive:\workingBicep.bicep' -Target $Pattern} | Should -Throw -ExpectedMessage 'Cannot validate argument on parameter ''Target''. Target does not match pattern for registry. Specify a path to a registry using "br:", or "br/" if using an alias.'
            }
        }
    }
}

