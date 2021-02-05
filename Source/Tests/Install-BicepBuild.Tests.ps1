Describe "Testing Install-BicepBuild" {
    Context "No previously installed bicep CLI" {
        It "Should install bicep" {
            {throw 'No bicep found'} | should -Not -Throw
        }
    }
}