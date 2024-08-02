BeforeAll {
    Import-Module -FullyQualifiedName "$PSScriptRoot\..\output\Bicep" -ErrorAction Stop
    Copy-Item "$PSScriptRoot\supportFiles\*" -Destination TestDrive:\
}

Describe 'Restore-Bicep' {
    Context 'When it works' { 
        It 'Restore Bicep' {
            {Restore-Bicep -Path 'TestDrive:\workingBicep.bicep'} | Should -Not -Throw        
        }        
    }    
}