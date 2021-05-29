try {
    $ScriptDirectory = Split-Path -Path $PSCommandPath -Parent
    Import-Module -FullyQualifiedName "$ScriptDirectory\..\Source\Bicep.psd1"
}
catch {
    Throw "Unable to import Bicep module. $_"
}

InModuleScope Bicep {
    BeforeAll {
        $ScriptDirectory = Split-Path -Path $PSCommandPath -Parent
    }
    Describe 'Build-Bicep' {
        
        Context 'When it works' {            
            It 'Build a bicep file AsString' {
                Build-Bicep -Path "$ScriptDirectory\supportFiles\workingBicep.bicep" -AsString | Should -Not -BeNullOrEmpty
            }
            It 'Build a bicep file AsHashtable' {
                Build-Bicep -Path "$ScriptDirectory\supportFiles\workingBicep.bicep" -AsHashtable | Should -Not -BeNullOrEmpty
            }
            It 'Build a bicep file' {
                $file="$ScriptDirectory\supportFiles\workingBicep.bicep"
                Build-Bicep -Path $file
                $templateFile = $file -replace '\.bicep', '.json'
                Get-Content -Path $templateFile -Raw | Should -Not -BeNullOrEmpty
            }
            It 'Build a bicep file and generate parameters' {
                $file="$ScriptDirectory\supportFiles\workingBicep.bicep"
                Build-Bicep -Path $file -GenerateAllParametersFile
                $parameterFile = $file -replace '\.bicep', '.parameters.json'
                Get-Content -Path $parameterFile -Raw | Should -Not -BeNullOrEmpty
            }

        }
        Context 'When it does not work' { 
            It 'Does not generate ARM template' {
                Build-Bicep -Path "$ScriptDirectory\supportFiles\brokenBicep.bicep" -AsString -IgnoreDiagnostics | Should -BeNullOrEmpty
            }

            It 'Diagnostics' {
                Build-Bicep -Path "$ScriptDirectory\supportFiles\brokenBicep.bicep" -AsString 6>&1 -ErrorAction SilentlyContinue | Should -BeLike '*Error BCP018: Expected the "}" character at this location.'
            }

            
        }
    }
}