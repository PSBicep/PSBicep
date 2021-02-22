function Get-BicepApiReference {
    [CmdletBinding(DefaultParameterSetName = 'TypeString')]
    param(
        [Parameter(Mandatory, 
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
                $Global:BicepResourceProviders.Resource | Where-Object { $_ -like "$wordToComplete*" } | Sort-Object -Unique
            }

        })]
        [string]$Resource,
        
        [Parameter(ParameterSetName = 'ResourceProvider')]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ $Global:BicepResourceProviders.Child -contains $_ }, 
                          ErrorMessage = "Child '{0}' was not found.")]
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
                    $BoundParameters.Child -like "$wordToComplete*"
                } | Select-Object -ExpandProperty Child | Sort-Object
            }
            else {
                $Global:BicepResourceProviders.Child | Where-Object { $_ -like "$wordToComplete*" } | Sort-Object -Unique -Descending
            }

        })]
        [string]$Child,

        [Parameter(ParameterSetName = 'ResourceProvider')]
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
                } | Select-Object -ExpandProperty ApiVersion | Sort-Object -Descending
            }
            elseif ($BoundParameters.ContainsKey('ResourceProvider') -and $BoundParameters.ContainsKey('Resource') -and $BoundParameters.ContainsKey('Child')) {
                $Global:BicepResourceProviders | Where-Object {
                    $_.ResourceProvider -eq $BoundParameters.ResourceProvider -and 
                    $_.Resource -eq $BoundParameters.Resource -and
                    $_.Child -eq $BoundParameters.Child -and 
                    $BoundParameters.ApiVersion -like "$wordToComplete*"
                } | Select-Object -ExpandProperty ApiVersion | Sort-Object -Descending
            }
            else {
                $Global:BicepResourceProviders.ApiVersion | Where-Object { $_ -like "$wordToComplete*" } | Sort-Object -Unique -Descending
            }

        })]
        [string]$ApiVersion,

        [Parameter(ParameterSetName = 'TypeString',
                   Position = 0)]
        [ValidateScript({ $_ -like '*/*' -and $_ -like '*@*' },
                          ErrorMessage = "Type must contain '/' and '@'.")]
        [ArgumentCompleter({
            param ( 
                $commandName,
                $parameterName,
                $wordToComplete,
                $commandAst,
                $BoundParameters
            )

            $Global:BicepResourceProviders.FullName | Where-Object { $_ -like "$wordToComplete*" } | Sort-Object -Unique -Descending

        })]
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

             }
            'TypeString' {
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
               
                if ([string]::IsNullOrEmpty($TypeChild)) {
                    $url = "$BaseUrl/$TypeResourceProvider/$TypeApiVersion/$TypeResource"
                }
                else {
                    $url = "$BaseUrl/$TypeResourceProvider/$TypeApiVersion/$TypeResource/$TypeChild"
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
            Write-Error "No documentation found. This usually means that no documentation has been written. If you would like to try anyway, use the -Force parameter. Url: $url"      
        }
    }

}
