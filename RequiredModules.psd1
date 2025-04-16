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
                                        Version = '2.4.0'
                                        MaximumVersion = '2.99.99'
                                    }
    'Azure/Bicep'                 = 'v0.34.44'
}