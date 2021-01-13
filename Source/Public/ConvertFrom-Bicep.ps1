function ConvertFrom-Bicep {
    param(
        [string]$Path = $pwd.path
    )

    if (TestBicep) {
        $files = Get-Childitem -Path $Path *.json -File
        if ($files) {
            foreach ($file in $files) {
                bicep decompile $file
            }   
        }
        else {
            Write-Host "No bicep files located in path $Path"
        } 
    }
    else {
        Write-Error "Cannot find the Bicep CLI. Install Bicep CLI using Install-BicepCLI."
    }    
}