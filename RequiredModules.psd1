@{
    PSDependOptions               = @{
        AddToPath  = $true
        Target     = 'output\RequiredModules'
        Parameters = @{
            Repository = 'PSGallery'
        }
    }
    InvokeBuild                   = 'latest'
    PSScriptAnalyzer              = 'latest'
    Pester                        = 'latest'
    ModuleBuilder                 = 'latest'
    ChangelogManagement           = 'latest'
    Sampler                       = 'latest'
    'Sampler.GitHubTasks'         = 'latest'
    MarkdownLinkCheck             = 'latest'
    'SimonWahlin/platyPS'         = @{
                                        Version = 'V2'
                                        DependencyType = 'GitHub'
                                        Parameters = @{
                                            TargetType = 'Exact'
                                            ExtractPath = 'Microsoft.PowerShell.PlatyPS'
                                        }
                                    }
    'AzAuth'                      = @{
                                        Version = '2.6.0'
                                        MaximumVersion = '2.99.99'
                                    }
    'AzResourceGraph'             = @{
                                        Version = '0.2.1'
                                        MaximumVersion = '0.99.99'
    }
}