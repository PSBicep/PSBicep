function ParseBicep {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        $Path
    )

    process {
        $FileResolver = [Bicep.Core.FileSystem.FileResolver]::new()
        $WorkSpace = [Bicep.Core.Workspaces.Workspace]::new()
        $PathHelper = [Bicep.Core.FileSystem.PathHelper]::FilePathToFileUrl($Path)
        $ResourceTypeProvider = [Bicep.Core.TypeSystem.Az.AzResourceTypeProvider]::new()
        $SyntaxTreeGrouping = [Bicep.Core.Syntax.SyntaxTreeGroupingBuilder]::Build($FileResolver, $WorkSpace, $PathHelper)
        $Compilation = [Bicep.Core.Semantics.Compilation]::new($ResourceTypeProvider, $SyntaxTreeGrouping)
        $CompilationResults = $Compilation.GetAllDiagnosticsBySyntaxTree()
        
        New-Alias -Name 'Write-Info' -Value 'Write-Host' -Option Private
        foreach ($Key in $CompilationResults.Keys) {
            $DiagnosticResult = $CompilationResults[$Key]
            if ($DiagnosticResult.GetCount($false) -gt 0) {
                foreach ($Diagnostic in $DiagnosticResult) {
                    $Level = $Diagnostic.Level.ToString()
                    $Code = $Diagnostic.Code.ToString()
                    $Message = $Diagnostic.Message.ToString()
                    $OutputString = "'$Path : $Level ${Code}: $Message'"
        
                    & "Write-$($Diagnostic.Level)" $OutputString
                }
            }
        }
        Remove-Alias -Name 'Write-Info'

        $Emitter = [Bicep.Core.Emit.TemplateEmitter]::new($Compilation.GetEntrypointSemanticModel())
        $Stream = [System.IO.MemoryStream]::new()
        $EmitStatus = $Emitter.Emit($Stream)
        if ($EmitStatus.Status -ne [Bicep.Core.Emit.EmitStatus]::Succeeded) {
            # TODO: Better error handling
            throw 'Failed to emit to stream'
        }

        $Stream.Position = 0
        $Reader = [System.IO.StreamReader]::new($Stream)
        $String = $Reader.ReadToEnd()
        $Reader.Close()
        $Reader.Dispose()
        Write-Output $String
    }
}