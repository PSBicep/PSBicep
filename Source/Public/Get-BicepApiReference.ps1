function Get-BicepApiReference {
    [CmdletBinding(DefaultParameterSetName = 'TypeString')]
    param(
        [Parameter(Mandatory, 
            ParameterSetName = 'ResourceProvider')]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { (GetBicepTypes).ResourceProvider -contains $_ }, 
            ErrorMessage = "ResourceProvider '{0}' was not found.")]
        [ArgumentCompleter([BicepResourceProviderCompleter])]
        [string]$ResourceProvider,

        [Parameter(Mandatory, 
            ParameterSetName = 'ResourceProvider')]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { (GetBicepTypes).Resource -contains $_ }, 
            ErrorMessage = "Resource '{0}' was not found.")]
        [ArgumentCompleter([BicepResourceCompleter])]
        [string]$Resource,
        
        [Parameter(ParameterSetName = 'ResourceProvider')]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { (GetBicepTypes).Child -contains $_ }, 
            ErrorMessage = "Child '{0}' was not found.")]
        [ArgumentCompleter([BicepResourceChildCompleter])]
        [string]$Child,

        [Parameter(ParameterSetName = 'ResourceProvider')]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { (GetBicepTypes).ApiVersion -contains $_ }, 
            ErrorMessage = "ApiVersion '{0}' was not found.")]
        [ArgumentCompleter([BicepResourceApiVersionCompleter])]
        [string]$ApiVersion,

        [Parameter(ParameterSetName = 'TypeString',
            Position = 0)]
        [ValidateScript( { $_ -like '*/*' -and $_ -like '*@*' },
            ErrorMessage = "Type must contain '/' and '@'.")]
        [ArgumentCompleter([BicepTypeCompleter])]
        [string]$Type,

        [Parameter(ParameterSetName = 'TypeString')]
        [switch]$Latest,
        
        [Parameter(ParameterSetName = 'ResourceProvider')]
        [Parameter(ParameterSetName = 'TypeString')]
        [Alias('Please')]
        [switch]$Force
    )
    begin {
        if (-not $Script:ModuleVersionChecked) {
            TestModuleVersion
        }
    }
    
    process {
        $baseUrl = "https://docs.microsoft.com/en-us/azure/templates"
        $suffix = '?tabs=bicep'

        switch ($PSCmdlet.ParameterSetName) {
            
            'ResourceProvider' {
                $url = "$BaseUrl/$ResourceProvider" 
                
                # if ApiVersion is provided, we use that. Otherwise we skip version and go for latest
                if ($PSBoundParameters.ContainsKey('ApiVersion')) {
                    $url += "/$ApiVersion"
                }

                $url += "/$Resource"

                # Child is optional, so we only add it if provided
                if ($PSBoundParameters.ContainsKey('Child')) {
                    $url += "/$Child"
                }

                $url += $suffix
            }
            'TypeString' {
                if ($PSBoundParameters.ContainsKey('Type')) {
                    # Type looks like this:   Microsoft.Aad/domainServicess@2017-01-01
                    # Then we split here:                  ^               ^
                    # Or it looks like this:  Microsoft.ApiManagement/service/certificates@2019-12-01
                    # Then we split here:                            ^       ^            ^
                    # Lets not use regex. regex kills kittens

                    # First check if we have three parts before the @
                    # In that case the last one should be the child
                    if (($type -split '/' ).count -eq 3) {
                        $TypeChild = ( ($type -split '@') -split '/' )[2]
                    }  
                    else {
                        $TypeChild = $null
                    }

                    $TypeResourceProvider = ( ($type -split '@') -split '/' )[0]
                    $TypeResource = ( ($type -split '@') -split '/' )[1]
                    $TypeApiVersion = ( $type -split '@' )[1]
                
                    if ([string]::IsNullOrEmpty($TypeChild) -and ($Latest.IsPresent)) {
                        $url = "$BaseUrl/$TypeResourceProvider/$TypeResource"
                    }
                    elseif ([string]::IsNullOrEmpty($TypeChild)) {
                        $url = "$BaseUrl/$TypeResourceProvider/$TypeApiVersion/$TypeResource"
                    }
                    elseif ($Latest.IsPresent) {
                        $url = "$BaseUrl/$TypeResourceProvider/$TypeResource/$TypeChild"
                    }
                    else {
                        $url = "$BaseUrl/$TypeResourceProvider/$TypeApiVersion/$TypeResource/$TypeChild"
                    }

                    $url += $suffix
                }
                else {
                    # If Type is not provided, open the template start page
                    $url = $BaseUrl
                }
            }
        }
        
        # Check if there is any valid page on the generated Url
        # We don't want to send users to broken urls.
        try {
            $null = Invoke-WebRequest -Uri $url -ErrorAction Stop
            $DocsFound = $true
        }
        catch {
            $DocsFound = $false
        }

        # Now we know if its working or not. Open page or provide error message.
        if ($DocsFound -or $Force.IsPresent) {
            Start-Process $url
        }
        else {
            Write-Error "No documentation found. This usually means that no documentation has been written. Use the -Latest parameter to open the latest available API Version. Or if you would like to try anyway, use the -Force parameter. Url: $url"      
        }
    }
}
