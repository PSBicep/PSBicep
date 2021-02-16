function Get-BicepApiReference {
    [CmdletBinding(DefaultParameterSetName = 'TypeString')]
    param(
        [Parameter(Mandatory, 
                   Position = 0,
                   ParameterSetName = 'ResourceProvider')]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ $Global:BicepResourceProviders.ResourceProvider -contains $_ }, 
                          ErrorMessage = "ResourceProvider '{0}' was not found.")]
        [ArgumentCompleter({
            param ( 
                $commandName,
                $parameterName,
                $wordToComplete,
                $commandAst,
                $BoundParameters
            )

            $Global:BicepResourceProviders.ResourceProvider | Where-Object { $_ -like "$wordToComplete*" } | Sort-Object
        
        })]
        [string]$ResourceProvider,

        [Parameter(Mandatory, 
                   Position = 1,
                   ParameterSetName = 'ResourceProvider')]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ $Global:BicepResourceProviders.Resource -contains $_ }, 
                          ErrorMessage = "Resource '{0}' was not found.")]
        [ArgumentCompleter({
            param ( 
                $commandName,
                $parameterName,
                $wordToComplete,
                $commandAst,
                $BoundParameters
            )

            if ($BoundParameters.ContainsKey('ResourceProvider')) {
                $Global:BicepResourceProviders | Where-Object {
                    $_.ResourceProvider -eq $BoundParameters.ResourceProvider -and 
                    $_.Resource -like "$wordToComplete*"
                } | Select-Object -ExpandProperty Resource | Sort-Object
            }
            else {
                $Global:BicepResourceProviders.Resource | Sort-Object -Unique
            }

        })]
        [string]$Resource,
        
        [Parameter(Position = 2,
                   ParameterSetName = 'ResourceProvider')]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ $Global:BicepResourceProviders.ApiVersion -contains $_ }, 
                          ErrorMessage = "ApiVersion '{0}' was not found.")]
        [ArgumentCompleter({
            param ( 
                $commandName,
                $parameterName,
                $wordToComplete,
                $commandAst,
                $BoundParameters
            )

            if ($BoundParameters.ContainsKey('ResourceProvider') -and $BoundParameters.ContainsKey('Resource')) {
                $Global:BicepResourceProviders | Where-Object {
                    $_.ResourceProvider -eq $BoundParameters.ResourceProvider -and 
                    $_.Resource -eq $BoundParameters.Resource -and 
                    $BoundParameters.ApiVersion -like "$wordToComplete*"
                } | Select-Object -ExpandProperty ApiVersion | Sort-Object
            }
            else {
                $Global:BicepResourceProviders.Resource | Sort-Object -Unique
            }

        })]
        [string]$ApiVersion,

        [Parameter(ParameterSetName = 'TypeString',
                   Position = 0)]
        [ValidateScript({ $_ -like '*/*' -and $_ -like '*@*' },
                          ErrorMessage = "Type must contain '/' and '@'.")]
        [string]$Type,

        [Parameter(ParameterSetName = 'ResourceProvider')]
        [Parameter(ParameterSetName = 'TypeString')]
        [Alias('Please')]
        [switch]$Force
    )

    process {
        $baseUrl = "https://docs.microsoft.com/en-us/azure/templates"

        switch ($PSCmdlet.ParameterSetName) {
            'ResourceProvider' { 
                if ($PSBoundParameters.ContainsKey('ApiVersion')) {
                    # Specified API Verion
                    $url = "$BaseUrl/$ResourceProvider/$ApiVersion/$Resource"
                }
                else {
                    # Latest API Version
                    $url = "$BaseUrl/$ResourceProvider/$Resource"
                }
             }
            'TypeString' {
                # Type should look like this: Microsoft.Aad/domainServicess@2017-01-01
                # We want to split here:                   ^               ^
                # Lets not use regex. regex kills kittens
                $TypeResourceProvider = ($type -split "/")[0]
                $TypeResource = (($type -split "/")[1] -split '@')[0]
                $TypeApiVersion = ($type -split "@")[1]
               
                $url = "$BaseUrl/$TypeResourceProvider/$TypeApiVersion/$TypeResource"
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
            Write-Error "No documentation found. This usually means that no documentation has been written. If you would like to try anyway, use the -Force parameter. Url: $url"      
        }
    }

}

