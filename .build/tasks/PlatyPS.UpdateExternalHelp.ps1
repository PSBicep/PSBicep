task updateExternalHelp {
    Import-Module 'platyPS' -ErrorAction 'Stop'
    New-ExternalHelp .\Docs\Help -OutputPath .\Source\en-US\ -Force
}