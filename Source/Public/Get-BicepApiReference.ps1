


function Get-BicepApiReference {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ResourceProvider,
        [Parameter(Mandatory = $true)]
        [string]$Resource,
        [string]$ApiVersion
    )

    $baseUrl = "https://docs.microsoft.com/en-us/azure/templates"

    if ($ApiVersion) {
        #Get specified API Verion
        $url = "$BaseUrl/$ResourceProvider/$ApiVersion/$Resource"
    }
    else {
        #Get latest API Version
        $url = "$BaseUrl/$ResourceProvider/$Resource"
    }
        
    Start-Process $url

}