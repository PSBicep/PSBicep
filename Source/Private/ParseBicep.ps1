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

        $Success = $true
        foreach ($SyntaxTree in $CompilationResults.Keys) {
            $DiagnosticResult = $CompilationResults[$SyntaxTree]
            if ($DiagnosticResult.GetCount($false) -gt 0) {
                foreach ($Diagnostic in $DiagnosticResult) {
                    # If any diagnostic is an error
                    if ((WriteBicepDiagnostic -Diagnostic $Diagnostic -SyntaxTree $SyntaxTree) -eq $false) {
                        $Success = $false
                    }
                }
            }
        }

        if ($Success) {
            $Emitter = [Bicep.Core.Emit.TemplateEmitter]::new($Compilation.GetEntrypointSemanticModel())
            $Stream = [System.IO.MemoryStream]::new()
            $EmitResult = $Emitter.Emit($Stream)
            foreach ($Diagnostic in $EmitResult.Diagnostics) {
                if ($EmitResult.Status -ne [Bicep.Core.Emit.EmitStatus]::Succeeded) {
                    WriteBicepDiagnostic $Diagnostic
                }
            }

            $Stream.Position = 0
            $Reader = [System.IO.StreamReader]::new($Stream)
            $String = $Reader.ReadToEnd()
            $Reader.Close()
            $Reader.Dispose()

            Write-Output $String
        }
    }
}