function InstalledBicepVersion {   
    if (TestBicep) {
        $Version=((bicep --version) -split "\s+")[3]
        "v$Version"
    } else {
        "Not installed"
    }  
}