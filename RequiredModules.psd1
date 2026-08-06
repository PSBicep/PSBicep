@{
    PSDependOptions                = @{
        AddToPath  = $True
        Target     = 'output\RequiredModules'
        Parameters = @{
            Repository = 'PSGallery'
        }
    }
    AzAuth                         = '2.9.0'
    AzResourceGraph                = '0.2.1'
    'Microsoft.PowerShell.PlatyPS' = '1.0.2'
    'Sampler.GitHubTasks'          = '0.4.1'
    ChangelogManagement            = '3.1.0'
    InvokeBuild                    = '5.14.23'
    MarkdownLinkCheck              = '0.2.0'
    Metadata                       = '1.5.7'
    ModuleBuilder                  = '3.2.18'
    Pester                         = '6.0.1'
    PSScriptAnalyzer               = '1.25.0'
    Sampler                        = '0.120.0'
}
