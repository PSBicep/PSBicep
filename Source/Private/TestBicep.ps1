function TestBicep {
    $bicep = (Get-Command Bicep -ErrorAction SilentlyContinue)
    if ($bicep) {
        $true
    }
    else {
        $false
    }
}