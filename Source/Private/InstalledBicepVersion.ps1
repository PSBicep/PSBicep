function InstalledBicepVersion {   
    if (TestBicep) {
        ((bicep --version) -split "\s+")[3]
    } else {
        "Not installed"
    }  
}