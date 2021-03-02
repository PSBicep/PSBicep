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
        $DiagnosticParams = foreach ($SyntaxTree in $CompilationResults.Keys) {
            $DiagnosticResult = $CompilationResults[$SyntaxTree]
            if ($DiagnosticResult.GetCount($false) -gt 0) {
                foreach ($Diagnostic in $DiagnosticResult) {
                    $Params = WriteBicepDiagnostic -Diagnostic $Diagnostic -SyntaxTree $SyntaxTree
                    Write-Information @Params -InformationAction 'Continue'
                    Write-Output $Params

                    if ($Diagnostic.Level -eq [Bicep.Core.Diagnostics.DiagnosticLevel]::Error) {
                        $Success = $false
                    }
                }
            }
        }
        
        if ($DiagnosticParams.Tag -eq 'Error') {
            $ErrorParams = @{
                Message           = "Buildning file $Path returned with errors. See Information stream for details"
                Category          = 'InvalidResult' 
                RecommendedAction = 'Check for errors in the Information stream.'
                TargetObject      = $Path
            }
            Write-Error @ErrorParams
            return
        }

        if ($Success) {
            $Emitter = [Bicep.Core.Emit.TemplateEmitter]::new($Compilation.GetEntrypointSemanticModel())
            $Stream = [System.IO.MemoryStream]::new()
            $EmitResult = $Emitter.Emit($Stream)
            if ($EmitResult.Status -ne [Bicep.Core.Emit.EmitStatus]::Failed) {
                $Stream.Position = 0
                $Reader = [System.IO.StreamReader]::new($Stream)
                $String = $Reader.ReadToEnd()
                $Reader.Close()
                $Reader.Dispose()
        
                Write-Output $String
            }
        }
    }
}