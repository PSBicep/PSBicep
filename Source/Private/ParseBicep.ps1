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
        $syntaxTreeGrouping = [Bicep.Core.Syntax.SyntaxTreeGroupingBuilder]::Build($FileResolver, $WorkSpace, $PathHelper)
        $compilation = [Bicep.Core.Semantics.Compilation]::new($ResourceTypeProvider, $syntaxTreeGrouping)
        $compilationResults, $diagnostics = $compilation.GetAllDiagnosticsBySyntaxTree()
        
        $success = $true
        foreach ($diagnostic in $diagnostics) {
            $success = $success -and ($diagnostic.Level -ne [Bicep.Core.Diagnostics.DiagnosticLevel]::Error)
        }

        if (-not $success) { 
            # TODO: Better error handling
            throw 'FAILURE'
        }

        $emitter = [Bicep.Core.Emit.TemplateEmitter]::new($compilation.GetEntrypointSemanticModel())
        $Stream = [System.IO.MemoryStream]::new()
        $EmitStatus = $emitter.Emit($Stream)
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