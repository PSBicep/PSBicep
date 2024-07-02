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
    'Azure/Bicep'                 = 'v0.28.1'
}