function InstalledBicepVersion {
    ((bicep --version) -split "\s+")[3]
}