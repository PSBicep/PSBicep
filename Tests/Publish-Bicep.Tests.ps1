BeforeAll {
    $ScriptDirectory = Split-Path -Path $PSCommandPath -Parent
    Import-Module -FullyQualifiedName "$ScriptDirectory\..\Source\Bicep.psd1" -ErrorAction Stop

    $ScriptDirectory = Split-Path -Path $PSCommandPath -Parent
    Copy-Item "$ScriptDirectory\supportFiles\*" -Destination TestDrive:\
}

Describe 'Publish-Bicep' {
    Context 'When it does not work' { 
        It 'Non existing scheme' {
            {Publish-Bicep -Path 'TestDrive:\workingBicep.bicep' -Target 'psbicep:bicepmodules.azurecr.io/bicep/storage:v1'} | Should -Throw "The specified module reference scheme*"
        }

        It 'Broken bicep file' {
            {Publish-Bicep -Path 'TestDrive:\brokenBicep.bicep' -Target 'br:bicepmodules.azurecr.io/bicep/storage:v1'} | Should -Throw "The provided bicep is not valid. Make sure that your bicep file builds successfully before publishing."
        }        
    }    
}