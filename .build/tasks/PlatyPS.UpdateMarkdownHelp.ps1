task updateMarkdownHelp {
    Import-Module 'platyPS' -ErrorAction 'Stop'
    $ProjectName = Get-SamplerProjectName -BuildRoot $BuildRoot
    Import-Module $BuildModuleOutput/$ProjectName -Force -ErrorAction 'Stop'
    New-MarkdownHelp -Module $ProjectName -OutputFolder $BuildInfo.PlatyPS.HelpMarkdownFolder -Force
}