[cmdletbinding()]
param (
    [Parameter(DontShow)]
    $BaseUri = 'https://api.github.com'
)

if(-not(Get-Command 'dotnet')) {
    throw 'This requires dotnet 5 SDK to be installed'
}

try {
    if($PSScriptRoot) {
        Push-Location $PSScriptRoot -StackName 'downloadDependencies'
    }
    Remove-Item -Path './tmp' -Recurse -Force -ErrorAction 'Ignore'
    $null = New-Item -Path '../Source/Assets' -ItemType Directory -ErrorAction Ignore
    $AssetsFolder = Resolve-Path -Path '../Source/Assets'
    $AssemblyVersion = Get-Content -Path '../Source/assemblyversion.txt' -ErrorAction 'Stop'
    
    $null = New-Item -Path './tmp' -ItemType Directory -ErrorAction Ignore
    Push-Location -Path './tmp' -StackName 'downloadDependencies'
    Write-Verbose -Message "Cloning Bicep sources using tag: $AssemblyVersion" -Verbose
    git clone 'https://github.com/Azure/bicep.git'
    Push-Location -Path './bicep' -StackName 'downloadDependencies'
    git checkout tags/$AssemblyVersion
    Push-Location -Path './src' -StackName 'downloadDependencies'
    dotnet publish './Bicep.Cli' -c 'Release' --no-self-contained --nologo --verbosity 'minimal'
    $FilesToInclude = @(
        'Azure.Bicep.Types.dll',
        'Azure.Bicep.Types.Az.dll',
        'Azure.Deployments.Core.dll',
        'Azure.Deployments.Expression.dll', 
        'Bicep.Core.dll',
        'Bicep.Decompiler.dll'
    )
    $Files = Get-Item -Path '.\Bicep.Cli\bin\Release\net5.0\publish\*' -Include $FilesToInclude
    $Files | Copy-Item -Destination $AssetsFolder.Path -Force

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



