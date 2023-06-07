BeforeAll {
    $ScriptDirectory = Split-Path -Path $PSCommandPath -Parent
    Import-Module -FullyQualifiedName (Join-Path $PSScriptRoot '..\Source\Bicep.psd1') -ErrorAction Stop
}

Describe "ConvertToHashTable" {
    Context "ContextName" {
        BeforeAll {
            InModuleScope -ModuleName Bicep {
                $Script:InputObject = [PSCustomObject]@{
                    Name = 'Value'
                    Color = 'Red'
                    Number = 1
                }

                $Script:ComplexInputObject = [PSCustomObject]@{
                    ChildObject = $InputObject
                    Array = @('Value1', 'Value2')
                    HashTable = @{
                        Name = 'Value'
                    }
                    OrderedHashTable = [ordered]@{
                        Name = 'Value'
                    }
                    EmptyArray = @()
                }
            }
        }

        It "Returns a hashtable when input is a regular object" {
            InModuleScope -ModuleName Bicep {
                ConvertToHashTable -InputObject $InputObject | Should -BeOfType Hashtable
            }
        }

        It "Returns a string when input is string" {
            InModuleScope -ModuleName Bicep {
                ConvertToHashTable -InputObject 'this is a string' | Should -BeOfType [String]
            }
        }

        It "Returns a value type when input is a value type" {
            InModuleScope -ModuleName Bicep {
                (ConvertToHashTable -InputObject 1).Gettype().BaseType.Name | Should -Be 'ValueType'
            }
        }

        It "Returns a hashtable when input is a hashtable" {
            InModuleScope -ModuleName Bicep {
                ConvertToHashTable -InputObject @{key='value'} | Should -BeOfType [System.Collections.Hashtable]
            }
        }

        It "Returns an ordered hashtable when input is a hashtable" {
            InModuleScope -ModuleName Bicep {
                ConvertToHashTable -InputObject ([ordered]@{key='value'}) | Should -BeOfType [System.Collections.Specialized.OrderedDictionary]
            }
        }

        It "Returns correct hash table" {
            InModuleScope -ModuleName Bicep {
                $ConvertedObject = ConvertToHashTable -InputObject $InputObject
                $ConvertedObject['Name'] | Should -Be 'Value'
                $ConvertedObject['Color'] | Should -Be 'Red'
                $ConvertedObject['Number'] | Should -Be 1
            }
        }

        It "Returns unordered hash table by default" {
            InModuleScope -ModuleName Bicep {
                ConvertToHashTable -InputObject $InputObject | Should -BeOfType [hashtable]
            }
        }

        It "Returns nordered hash table when Ordered parameter is used" {
            InModuleScope -ModuleName Bicep {
                ConvertToHashTable -InputObject $InputObject -Ordered | Should -BeOfType [System.Collections.Specialized.OrderedDictionary]
            }
        }
        
        It "Handles complex objects flawlessly" {
            InModuleScope -ModuleName Bicep {
                ConvertToHashtable -InputObject $ComplexInputObject | Should -BeOfType Hashtable
            }
        }
        
    }
}