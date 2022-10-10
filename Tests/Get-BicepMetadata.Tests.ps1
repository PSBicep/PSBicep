BeforeAll {
    $ScriptDirectory = Split-Path -Path $PSCommandPath -Parent
    Import-Module -FullyQualifiedName "$ScriptDirectory\..\Source\Bicep.psd1" -ErrorAction Stop
}

Describe 'Get-BicepMetadata tests' {
    BeforeAll {
        $ScriptDirectory = Split-Path -Path $PSCommandPath -Parent
        $null = New-Item -ItemType 'Directory' -Path 'TestDrive:\supportFiles' -ErrorAction 'Ignore'
        Copy-Item "$ScriptDirectory\supportFiles\*" -Destination 'TestDrive:\supportFiles'
    }

    Context 'Parameters' {
        It 'Should have parameter Path' {
                (Get-Command Get-BicepMetadata).Parameters.Keys | Should -Contain 'Path'
        }
        It 'Should have parameter OutputType' {
                (Get-Command Get-BicepMetadata).Parameters.Keys | Should -Contain 'OutputType'
        }
        It 'Should have parameter IncludeReservedMetadata' {
            (Get-Command Get-BicepMetadata).Parameters.Keys | Should -Contain 'IncludeReservedMetadata'
    }
    }

    Context 'Get Bicep Metadata' {
            
        BeforeAll {
            $jsonMeta = @'
            {
                "pesterMeta": {
                    "author": "PSBicep",
                    "version": "v1.0",
                    "aNumber": 1
                }
            }
'@
            $hashMeta=@{
                pesterMeta=@{
                    author="PSBicep"
                    version="v1.0"
                    aNumber=1
                }
            }
        }

        It 'Returns default output when used without parameters' {
            $defaultMetadata = Get-BicepMetadata -Path "$TestDrive\supportFiles\bicepWithMeta.bicep"
            $defaultMetadata.pesterMeta.author | Should -BeExactly "PSBicep"
        }

        It 'Returns json output' {
            $meta = Get-BicepMetadata -Path "$TestDrive\supportFiles\bicepWithMeta.bicep" -OutputType Json
            $jsonMetaTest = ConvertFrom-Json -InputObject $jsonMeta | ConvertTo-Json -Depth 10
            $MetaJson = ConvertFrom-Json -InputObject $meta | ConvertTo-Json -Depth 10
            $MetaJson | Should -BeExactly $jsonMetaTest
        }
        
        It 'Returns hashtable output' {
            $hashMetadata = Get-BicepMetadata -Path "$TestDrive\supportFiles\bicepWithMeta.bicep" -OutputType Hashtable
            $hashMetadata.pesterMeta.author | Should -BeExactly $hashMeta.pesterMeta.author
        }

        It 'Returns reserved metadata' {
            $hashMetadata = Get-BicepMetadata -Path "$TestDrive\supportFiles\bicepWithMeta.bicep" -IncludeReservedMetadata
            $hashMetadata._generator | Should -Not -BeNullOrEmpty
        }
    }
}
