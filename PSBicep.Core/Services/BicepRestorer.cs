using System.Threading.Tasks;
using Bicep.Core;
using Bicep.Core.FileSystem;
using Microsoft.Extensions.Logging;
using Microsoft.VisualStudio.Threading;
using PSBicep.Core.Logging;
using PSBicep.Core.Models;

namespace PSBicep.Core.Services;

public class BicepRestorer
{
    private readonly JoinableTaskFactory _joinableTaskFactory;
    private readonly BicepCompiler _compiler;
    private readonly DiagnosticLogger _diagnosticLogger;
    private readonly ILogger _logger;

    public BicepRestorer(
        JoinableTaskFactory joinableTaskFactory,
        BicepCompiler compiler,
        DiagnosticLogger diagnosticLogger,
        ILogger logger)
    {
        _joinableTaskFactory = joinableTaskFactory;
        _compiler = compiler;
        _diagnosticLogger = diagnosticLogger;
        _logger = logger;
    }

    public void Restore(string inputFilePath, bool forceModulesRestore = false) =>
        _joinableTaskFactory.Run(() => RestoreAsync(inputFilePath, forceModulesRestore));

    public async Task RestoreAsync(string inputFilePath, bool forceModulesRestore = false)
    {
        _logger?.LogTrace("Restoring external modules to local cache for file {inputFilePath}", inputFilePath);
        var inputPath = PathHelper.ResolvePath(inputFilePath);
        var inputUri = PathHelper.FilePathToFileUrl(inputPath);

        var compilation = _compiler.CreateCompilationWithoutRestore(inputUri, markAllForRestore: forceModulesRestore);
        var restoreDiagnostics = await _compiler.Restore(compilation, forceRestore: forceModulesRestore);
        _diagnosticLogger.LogDiagnostics(DiagnosticOptions.Default, restoreDiagnostics);
    }
}