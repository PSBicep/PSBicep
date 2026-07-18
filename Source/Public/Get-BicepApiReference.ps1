function Get-BicepApiReference {
    [CmdletBinding(DefaultParameterSetName = 'TypeString')]
    param(
        [Parameter(Mandatory, 
            ParameterSetName = 'ResourceProvider')]
        [ValidateNotNullOrEmpty()]
        [ArgumentCompleter([PSBicep.Completers.BicepResourceProviderCompleter])]
        [string]$ResourceProvider,

        [Parameter(Mandatory, 
            ParameterSetName = 'ResourceProvider')]
        [ValidateNotNullOrEmpty()]
        [ArgumentCompleter([PSBicep.Completers.BicepResourceCompleter])]
        [string]$Resource,
        
        [Parameter(ParameterSetName = 'ResourceProvider')]
        [ValidateNotNullOrEmpty()]
        [ArgumentCompleter([PSBicep.Completers.BicepResourceChildCompleter])]
        [string]$Child,

        [Parameter(ParameterSetName = 'ResourceProvider')]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^\d{4}-\d{2}-\d{2}(-Preview)?$', ErrorMessage = "ApiVersion must be in the format YYYY-MM-DD or YYYY-MM-DD-Preview.")]
        [ArgumentCompleter([PSBicep.Completers.BicepResourceApiVersionCompleter])]
        [string]$ApiVersion,

        [Parameter(ParameterSetName = 'TypeString',
            Position = 0)]
        [ValidateScript( { $_ -like '*/*' },
            ErrorMessage = "Type must contain '/'.")]
        [ArgumentCompleter([PSBicep.Completers.BicepTypeCompleter])]
        [string]$Type,

        [Parameter(ParameterSetName = 'TypeString')]
        [switch]$Latest,
        
        [Parameter(ParameterSetName = 'ResourceProvider')]
        [Parameter(ParameterSetName = 'TypeString')]
        [Alias('Please')]
        [switch]$Force,

        [Parameter(ParameterSetName = 'ResourceProvider')]
        [Parameter(ParameterSetName = 'TypeString')]
        [switch]$ReturnUri
    )

    begin {
        if (-not $Force.IsPresent -and $PSCmdlet.ParameterSetName -eq 'ResourceProvider') {

            # Validate that the provided ResourceProvider is valid
            if ($PSBoundParameters.ContainsKey('ResourceProvider')) {
                if ($null -eq (Get-BicepResourceProvider -ResourceProvider $ResourceProvider -ExactMatch)) {
                    throw "Cannot validate argument on parameter 'ResourceProvider'. The Resource Provider '$ResourceProvider' was not found. Use -Force to bypass this validation."
                }
            }

            # Validate that the provided Resource is valid for the specified resource provider
            if ($PSBoundParameters.ContainsKey('Resource')) {
                if ($null -eq (Get-BicepResourceType -ResourceProvider $ResourceProvider -Resource $Resource -ExactMatch)) {
                    throw "Cannot validate argument on parameter 'Resource'. The Resource '$Resource' was not found for the specified resource provider. Use -Force to bypass this validation."
                }
            }

            # Validate that the provided Child is valid for the specified resource type
            if ($PSBoundParameters.ContainsKey('Child')) {
                if ($null -eq (Get-BicepChildResourceType -ResourceProvider $ResourceProvider -Resource $Resource -Child $Child -ExactMatch)) {
                    throw "Cannot validate argument on parameter 'Child'. The Child '$Child' was not found for the specified resource type. Use -Force to bypass this validation."
                }
            }
            # Validate that the provided ApiVersion is valid for the specified resource type
            if ($PSBoundParameters.ContainsKey('ApiVersion')) {
                if ((Get-BicepApiVersion -ResourceType (@($ResourceProvider, $Resource, $Child).Where{-Not [string]::IsNullOrEmpty($_)} -join '/')) -notcontains $ApiVersion) {
                    throw "Cannot validate argument on parameter 'ApiVersion'. The ApiVersion '$ApiVersion' was not found for the specified resource type. Use -Force to bypass this validation."
                }
            }
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
                    $TypeString, $TypeStringApiVersion = $Type -split '@'
                    if ($Latest.IsPresent) {
                        $TypeStringApiVersion = $null
                    }

                    $TypeStringProvider, $TypeStringResource = $TypeString -split '/', 2

                    $url = @($BaseUrl, $TypeStringProvider, $TypeStringApiVersion, $TypeStringResource).Where{$null -ne $_} -join '/'

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
            if ($ReturnUri) {
                Write-Output $url
            }
            else {
                Start-Process $url
            }
        }
        else {
            Write-Error "No documentation found. This usually means that no documentation has been written. Use the -Latest parameter to open the latest available API Version. Or if you would like to try anyway, use the -Force parameter. Url: $url"      
        }
    }
}
