task updateExternalHelp {
    $ProjectName = Get-SamplerProjectName -BuildRoot $BuildRoot

    $OutputDocsDestination = (Get-Item ./output/$ProjectName/**/en-US | Select-Object -Last 1).FullName
    Import-Module 'Microsoft.PowerShell.PlatyPS' -ErrorAction 'Stop'
    Measure-PlatyPSMarkdown -Path ./Docs/$ProjectName/*.md |
        Where-Object Filetype -match 'CommandHelp' |
        Import-MarkdownCommandHelp -Path {$_.FilePath} |
        Export-MamlCommandHelp -OutputFolder $OutputDocsDestination -Force

    $ModuleInfo = Import-Module -Name $ProjectName -PassThru -ErrorAction 'Stop'
    $newMarkdownCommandHelpSplat = @{
        ModuleInfo = $ModuleInfo
        OutputFolder = "./Docs"
        WithModulePage = $false
    }
    New-MarkdownCommandHelp @newMarkdownCommandHelpSplat
}
