task updateMarkdownHelp {
    Import-Module 'Microsoft.PowerShell.PlatyPS' -ErrorAction 'Stop'
    $ProjectName = Get-SamplerProjectName -BuildRoot $BuildRoot
    Import-Module $BuildModuleOutput/$ProjectName -Force -ErrorAction 'Stop'

    Measure-PlatyPSMarkdown -Path ./Docs/$ProjectName/*.md |
        Where-Object Filetype -match 'CommandHelp' |
        Update-MarkdownCommandHelp -Path {$_.FilePath} -NoBackup

    Measure-PlatyPSMarkdown -Path ./Docs/$ProjectName/*.md |
        Where-Object Filetype -match 'CommandHelp' |
        Import-MarkdownCommandHelp -Path {$_.FilePath} |
        Update-MarkdownModuleFile -Path ./Docs/$ProjectName/$ProjectName.md -NoBackup -Force
}