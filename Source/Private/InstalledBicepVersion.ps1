function InstalledBicepVersion {   
    if (TestBicep) {
        $Version=((bicep --version) -split "\s+")[3]
        "$Version"
    } else {
        "Not installed"
    }  
}