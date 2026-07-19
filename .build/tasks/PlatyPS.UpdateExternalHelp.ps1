task updateExternalHelp {
    $ProjectName = Get-SamplerProjectName -BuildRoot $BuildRoot
    $ModuleInfo = Import-Module -Name $ProjectName -PassThru -Force -ErrorAction 'Stop'

    $OutputDocsDestination = Join-Path -Path $ModuleInfo.ModuleBase -ChildPath 'en-US'
    Import-Module 'Microsoft.PowerShell.PlatyPS' -ErrorAction 'Stop'
    Measure-PlatyPSMarkdown -Path ./Docs/$ProjectName/*.md |
        Where-Object Filetype -match 'CommandHelp' |
        Import-MarkdownCommandHelp -Path {$_.FilePath} |
        Export-MamlCommandHelp -OutputFolder $OutputDocsDestination -Force

    $newMarkdownCommandHelpSplat = @{
        ModuleInfo = $ModuleInfo
        OutputFolder = "./Docs"
        WithModulePage = $false
    }
    New-MarkdownCommandHelp @newMarkdownCommandHelpSplat
}
