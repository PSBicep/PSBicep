function TestBicep {
    $bicep = (bicep --version)
    if ($bicep) {
        $true
    }
    else {
        $false
    }
}