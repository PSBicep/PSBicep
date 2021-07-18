@{
    Path = "Bicep.psd1"
    OutputDirectory = "..\bin\Bicep"
    SourceDirectories = 'Classes','Private','Public'
    PublicFilter = 'Public\*.ps1'
    VersionedOutputDirectory = $true
    CopyPaths = @('Assets','BicepNet.PS','../LICENSE')
}