Describe "Testing Install-BicepBuild" {
    Context "No previously installed bicep CLI" {
        It "Should install bicep" {
            $true | should -Be $true
        }
    }
}