
Remove-Module Bicep -ErrorAction SilentlyContinue
Import-Module -FullyQualifiedName (Join-Path $PSScriptRoot '..\Source\Bicep.psd1') -ErrorAction Stop

InModuleScope -ModuleName Bicep {
    Describe 'Clear-BicepModuleCache tests' {

        Context 'Parameters' {
            It 'Should have parameter Oci' {
                (Get-Command Clear-BicepModuleCache).Parameters.Keys | Should -Contain 'Oci'
            }
            It 'Should have parameter Registry' {
                (Get-Command Clear-BicepModuleCache).Parameters.Keys | Should -Contain 'Registry'
            }
            It 'Should have parameter Repository' {
                (Get-Command Clear-BicepModuleCache).Parameters.Keys | Should -Contain 'Repository'
            }
            It 'Should have parameter TemplateSpecs' {
                (Get-Command Clear-BicepModuleCache).Parameters.Keys | Should -Contain 'TemplateSpecs'
            }
            It 'Should have parameter SubscriptionId' {
                (Get-Command Clear-BicepModuleCache).Parameters.Keys | Should -Contain 'SubscriptionId'
            }
            It 'Should have parameter ResourceGroup' {
                (Get-Command Clear-BicepModuleCache).Parameters.Keys | Should -Contain 'ResourceGroup'
            }
            It 'Should have parameter Spec' {
                (Get-Command Clear-BicepModuleCache).Parameters.Keys | Should -Contain 'Spec'
            }
            It 'Should have parameter Version' {
                (Get-Command Clear-BicepModuleCache).Parameters.Keys | Should -Contain 'Version'
            }
            It 'Should have parameter All' {
                (Get-Command Clear-BicepModuleCache).Parameters.Keys | Should -Contain 'All'
            }
        }
    }
}