BeforeAll {
    Import-Module -FullyQualifiedName "$PSScriptRoot\..\output\Bicep" -ErrorAction Stop
    Copy-Item "$PSScriptRoot\supportFiles\*" -Destination TestDrive:\
}

Describe 'Restore-Bicep' {
    Context 'When it works' { 
        It 'Restore Bicep' {
            # Restore-Bicep currently requires a token to work, not sure how to test this properly.
        }        
    }    
}