<#
    This test suite checks that the correct functions are exported from a module.
    Only functions located in the Public folder should be exported.
#>

#region Set up test cases
$ScriptDirectory = Split-Path -Path $PSCommandPath -Parent

# actual exported functions
$ExportedFunctions = (Get-Module -FullyQualifiedName "$ScriptDirectory\..\Source\Bicep.psd1" -ListAvailable -Refresh).ExportedFunctions.Keys
$ModuleName = (Get-ChildItem -Path "$ScriptDirectory\..\Source\Bicep.psm1").BaseName

# Create test cases for public functions
if (Test-Path -Path "$ScriptDirectory\..\Source\Public" -PathType Container) {
    $PublicFiles = Get-Childitem "$ScriptDirectory\..\Source\Public\*.ps1"
    $PublicFunctions = $PublicFiles.Name -replace '\.ps1$'

    $PublicTestCases = @()
    foreach ($PublicFunction in $PublicFunctions) {
        $PublicTestCases += @{
            Function = $PublicFunction
            ExportedFunctions = $ExportedFunctions
        }
    }
}

# Create test cases for private functions
if (Test-Path -Path "$ScriptDirectory\..\Source\Private" -PathType Container) {
    $PrivateFiles = Get-Childitem "$ScriptDirectory\..\Source\Private\*.ps1"
    $PrivateFunctions = $PrivateFiles.Name -replace '\.ps1$'

    $PrivateTestCases = @()
    foreach ($PrivateFunction in $PrivateFunctions) {
        $PrivateTestCases += @{
            Function = $PrivateFunction
            ExportedFunctions = $ExportedFunctions
        }
    }
}

# Import the module files before starting tests
BeforeAll {
    $ScriptDirectory = Split-Path -Path $PSCommandPath -Parent
    Import-Module -FullyQualifiedName (Join-Path $PSScriptRoot '..\Source\Bicep.psd1') -ErrorAction Stop
}

Describe "Module $ModuleName" {
    
    # A module should always have public functions
    # Its technically possible to not have any public functions. In that case, modify this script.
    Context 'Validate public functions' {
        
        It "Exported functions exist" -TestCases (@{ Count = $PublicTestCases.count }) {
            param ( $Count )
            $Count | Should -BeGreaterThan 0 -Because 'functions should exist'
        }

        It "Public function '<Function>' has been exported" -TestCases $PublicTestCases {
            param ( $Function,  $ExportedFunctions)
            $ExportedFunctions | Should -Contain $Function -Because 'the file is in the Public folder'
        }
    }

    # Only run test cases for private functions if we have any to run
    if ($PrivateTestCases.count -gt 0) {
        Context 'Validate private functions' {
            It "Private function '<Function>' has not been exported" -TestCases $PrivateTestCases {
                param ( $Function,  $ExportedFunctions)
                $ExportedFunctions | Should -Not -Contain $Function -Because 'the file is not in the Public folder'
            }
        }
    }

}