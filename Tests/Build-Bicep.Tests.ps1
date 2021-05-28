try {
    $ScriptDirectory = Split-Path -Path $PSCommandPath -Parent
    Import-Module -FullyQualifiedName "$ScriptDirectory\..\Source\Bicep.psd1"
    Import-Module -Name functional
}
catch {
    Throw "Unable to import Bicep module. $_"
}

InModuleScope Bicep {
    Describe 'Build-Bicep' {
        
        Context 'When it works' {            
            BeforeAll {
                $armTemaplate = Build-Bicep -Path .\supportFiles\workingBicep.bicep -AsString
            }
            It 'Build a bicep file' {
                $armTemaplate | Should -Not -BeNullOrEmpty
            }
        }
        Context 'When it does not work' {
            BeforeAll {                
                $armTemaplate = Build-Bicep -Path .\supportFiles\brokenBicep.bicep -AsString                
            }
            It 'Throws error if unable to get version file from GitHub' {
                $armTemaplate | Should -BeNullOrEmpty
            }
        }
    }
}