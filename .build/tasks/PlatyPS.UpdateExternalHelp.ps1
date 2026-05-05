task updateExternalHelp {
    Import-Module 'Microsoft.PowerShell.PlatyPS' -ErrorAction 'Stop'
    $ProjectName = Get-SamplerProjectName -BuildRoot $BuildRoot
    Measure-PlatyPSMarkdown -Path ./Docs/$ProjectName/*.md |
        Where-Object Filetype -match 'CommandHelp' |
        Import-MarkdownCommandHelp -Path {$_.FilePath} |
        Export-MamlCommandHelp -OutputFolder . | Foreach-Object {
            Move-Item -Path $_.FullName -Destination (
                Get-Item ./output/$ProjectName/**/en-US | Select-Object -Last 1
            ).FullName -Force
        }
}
