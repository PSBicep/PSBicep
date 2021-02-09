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
        Push-Location $PSScriptRoot -StackName 'downloadAssemblies'
    }
    Remove-Item -Path './tmp' -Recurse -Force -ErrorAction 'Ignore'
    $null = New-Item -Path '../Source/Assets' -ItemType Directory -ErrorAction Ignore
    $AssetsFolder = Resolve-Path -Path '../Source/Assets'
    $AssemblyVersion = Get-Content -Path '../Source/assemblyversion.txt' -ErrorAction 'Stop'
    $TagUri = '{0}/repos/Azure/bicep/releases/tags/{1}' -f $BaseUri, $AssemblyVersion
    $TagInfo = Invoke-RestMethod -Method 'GET' -Uri $TagUri
    
    $null = New-Item -Path './tmp' -ItemType Directory -ErrorAction Ignore
    Push-Location -Path './tmp' -StackName 'downloadAssemblies'
    Write-Verbose -Message 'Downloading Bicep sources'
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $TagInfo.zipball_url -OutFile './bicepSource.zip'
    Write-Verbose -Message 'Extracting sources'
    Expand-Archive -Path './bicepSource.zip' -Force
    Push-Location -Path './bicepSource/Azure-bicep-*/src' -StackName 'downloadAssemblies'
    dotnet publish './Bicep.Decompiler' -c 'Release' --no-self-contained --nologo --verbosity 'minimal'
    $FilesToInclude = @(
        'Azure.Bicep.Types.dll',
        'Azure.Bicep.Types.Az.dll',
        'Azure.Deployments.Core.dll',
        'Azure.Deployments.Expression.dll', 
        'Bicep.Core.dll',
        'Bicep.Decompiler.dll'
    )
    $Files = Get-Item -Path '.\Bicep.Decompiler\bin\Release\netstandard2.1\publish\*' -Include $FilesToInclude
    $Files | Copy-Item -Destination $AssetsFolder.Path -Force
}
finally {
    while(Get-Location -Stack -StackName 'downloadAssemblies' -ErrorAction 'Ignore') {
        Pop-Location -StackName 'downloadAssemblies'
    }
}



