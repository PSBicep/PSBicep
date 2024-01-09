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
    'BicepNet.PS'                 = '2.3.1'
    'SimonWahlin/platyPS' = @{
        Version = 'main'
        DependencyType = 'GitHub'
        Parameters = @{
            TargetType = 'Exact'
        }
    }
}