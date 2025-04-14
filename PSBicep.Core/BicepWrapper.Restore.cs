using System.Threading.Tasks;
using Bicep.Core.FileSystem;
using Microsoft.Extensions.Logging;
using PSBicep.Core.Logging;

namespace PSBicep.Core;

public partial class BicepWrapper
{
    public void Restore(string inputFilePath, bool forceModulesRestore = false) => joinableTaskFactory.Run(() => RestoreAsync(inputFilePath, forceModulesRestore));

    public async Task RestoreAsync(string inputFilePath, bool forceModulesRestore = false)
    {
        logger?.LogTrace("Restoring external modules to local cache for file {inputFilePath}", inputFilePath);
        var inputPath = PathHelper.ResolvePath(inputFilePath);
        var inputUri = PathHelper.FilePathToFileUrl(inputPath);

        var compilation = compiler.CreateCompilationWithoutRestore(inputUri, markAllForRestore: forceModulesRestore);
        var restoreDiagnostics = await compiler.Restore(compilation, forceRestore: forceModulesRestore);
        diagnosticLogger.LogDiagnostics(DiagnosticOptions.Default, restoreDiagnostics);
    }
}
