<#
    This test suite checks that the help files are correctly generated and contain the expected content.
#>

# Must be defined at script scope to be usable inside It descripions
$ModuleName = Get-SamplerProjectName -BuildRoot $PSScriptRoot/..

BeforeAll {
    # Import the PlatyPS module before running tests
    Import-Module -FullyQualifiedName "$PSScriptRoot/../output/RequiredModules/Microsoft.PowerShell.PlatyPS" -ErrorAction Stop
    # Must be defined inside to be usable within It-blocks
    $ModuleName = Get-SamplerProjectName -BuildRoot $PSScriptRoot/..
}

Describe "Module Help Generation" {

    Context 'Validate generated markdown help files' {
        It 'Generates markdown help files without errors' {
            $Diagnostics = Measure-PlatyPSMarkdown -Path "./Docs/$ModuleName/*.md" |
                Where-Object Filetype -match 'CommandHelp' |
                Import-MarkdownCommandHelp -Path {$_.FilePath} | Foreach-Object {
                    $item = $_
                    $item.Diagnostics.Messages | 
                        Where-Object Severity -in 'Error', 'Warning' | 
                        Where-Object Message -ne 'Notes content not found' | 
                        Select-Object -Property @{Name = 'Title'; Expression = {$item.Title}}, *
                }
            $Diagnostics | Should -BeNullOrEmpty -Because 'markdown help files should be generated without errors or warnings'
        }
        
        It "Does not contain placeholder text in ./Docs/$ModuleName/*.md files" {
            $PlaceholderRegex = '\{\{ [\s\w]+\}\}'
            $Placeholders = Select-String -Pattern $PlaceholderRegex -Path "./Docs/$ModuleName/*.md" -AllMatches
            $Placeholders | Foreach-Object {Write-Host $_ -ForegroundColor Yellow}
            $Placeholders | Should -BeNullOrEmpty -Because 'markdown help files should not contain placeholder text'
        }
    }
}