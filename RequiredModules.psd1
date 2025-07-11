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
                                        Version = 'main'
                                        DependencyType = 'GitHub'
                                        Parameters = @{
                                            TargetType = 'Exact'
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
    'Azure/Bicep'                 = 'v0.36.177'
}