[cmdletbinding()]
param (
    [Parameter()]
    $bicepNetVersion
)

try {

    if (-not $bicepNetVersion) {
        $bicepNetVersion = Get-Content -Path "$PSScriptRoot\..\.bicepNetVersion" -Raw
        $bicepNetVersion = $bicepNetVersion.Trim()
    }

    $BicepNetUrl = "https://github.com/PSBicep/BicepNet/releases/download/$bicepNetVersion/BicepNet.PS.zip"

    if ($PSScriptRoot) {
        Push-Location $PSScriptRoot -StackName 'downloadDependencies'
    }
    Remove-Item -Path './tmp' -Recurse -Force -ErrorAction 'Ignore'
    $null = New-Item -Path '../Source/Assets' -ItemType Directory -ErrorAction Ignore
    $AssetsFolder = Resolve-Path -Path '../Source/Assets'
    
    $null = New-Item -Path './tmp' -ItemType Directory -ErrorAction Ignore
    Push-Location -Path './tmp' -StackName 'downloadDependencies'
    
    Invoke-WebRequest -Uri $BicepNetUrl -OutFile 'BicepNet.PS.zip'
    Expand-Archive -Path ./BicepNet.PS.zip -DestinationPath '../../Source/' -Force
    
    # Download Bicep types
    $BicepTypesFull = Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/Azure/bicep-types-az/main/generated/index.json'
    if ($BicepTypesFull.psobject.Properties.name -notcontains 'Resources') {
        Throw "Bicep types not found."
    }
    
    # Filter out the resources and save to disk
    $BicepTypesFiltered = ConvertTo-Json -InputObject $BicepTypesFull.Resources.psobject.Properties.name -Compress
    $BicepTypesPath = Join-Path -Path $AssetsFolder.Path -ChildPath 'BicepTypes.json'
    Out-File -FilePath $BicepTypesPath -InputObject $BicepTypesFiltered -WhatIf:$WhatIfPreference
}
catch {
    Pop-Location -StackName 'downloadDependencies'
    throw
}
finally {
    while (Get-Location -Stack -StackName 'downloadDependencies' -ErrorAction 'Ignore') {
        Pop-Location -StackName 'downloadDependencies'
    }
}
