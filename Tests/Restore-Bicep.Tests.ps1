BeforeAll {
    $ScriptDirectory = Split-Path -Path $PSCommandPath -Parent
    Import-Module -FullyQualifiedName "$ScriptDirectory\..\Source\Bicep.psd1" -ErrorAction Stop

    $ScriptDirectory = Split-Path -Path $PSCommandPath -Parent
    Copy-Item "$ScriptDirectory\supportFiles\*" -Destination TestDrive:\
}

Describe 'Restore-Bicep' {
    Context 'When it works' { 
        It 'Restore Bicep' {
            {Restore-Bicep -Path 'TestDrive:\workingBicep.bicep'} | Should -Not -Throw        
        }        
    }    
}