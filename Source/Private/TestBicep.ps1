function TestBicep {
    $bicep = (Get-Command bicep -ErrorAction SilentlyContinue)
    if ($bicep) {
        $true
    }
    else {
        $false
    }
}