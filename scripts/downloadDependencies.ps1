[cmdletbinding()]
param (
    [Parameter()]
    $BicepNetUrl = 'https://github.com/PSBicep/BicepNet/releases/download/v1.0.2/BicepNet.PS.zip',
    
    [Parameter(DontShow)]
    $BaseUri = 'https://api.github.com'
)

try {
    if($PSScriptRoot) {
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
    $BicepTypesPath = Join-Path -Path $AssetsFolder.Path -ChildPath 'BicepTypes.json'
    $BicepTypesFull = Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/Azure/bicep-types-az/main/generated/index.json'
    $BicepTypesFiltered = ConvertTo-Json -InputObject $BicepTypesFull.types.psobject.Properties.name -Compress 
    Out-File -FilePath $BicepTypesPath -InputObject $BicepTypesFiltered -WhatIf:$WhatIfPreference
}
finally {
    while(Get-Location -Stack -StackName 'downloadDependencies' -ErrorAction 'Ignore') {
        Pop-Location -StackName 'downloadDependencies'
    }
}



