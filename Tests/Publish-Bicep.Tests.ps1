BeforeAll {
    $ScriptDirectory = Split-Path -Path $PSCommandPath -Parent
    Import-Module -FullyQualifiedName "$ScriptDirectory\..\Source\Bicep.psd1" -ErrorAction Stop

    $ScriptDirectory = Split-Path -Path $PSCommandPath -Parent
    Copy-Item "$ScriptDirectory\supportFiles\*" -Destination TestDrive:\
}

Describe 'Publish-Bicep' {
    Context 'When it works' {            
        It 'Publish Bicep' {
            Publish-Bicep -Path 'TestDrive:\workingBicep.bicep' -Target 'br:bicepmodules.azurecr.io/bicep/storage:v1' | Should -Not -Throw
        }
    }

    Context 'When it does not work' { 
        It 'Non existing scheme' {
            Publish-Bicep -Path 'TestDrive:\workingBicep.bicep' -Target 'psbicep:bicepmodules.azurecr.io/bicep/storage:v1' | Should -Throw  "The specified module reference scheme*"
        }

        It 'Broken bicep' {
            Publish-Bicep -Path 'TestDrive:\brokenBicep.bicep' -Target 'br:bicepmodules.azurecr.io/bicep/storage:v1' | Should -Throw "The template was not valid, please fix the template before publishing!"
        }        
    }    
}