using System;
using System.Threading.Tasks;
using Bicep.Core;
using Bicep.Core.FileSystem;
using Bicep.Core.SourceGraph;
using Microsoft.VisualStudio.Threading;
using PSBicep.Core.Logging;
using PSBicep.Core.Models;

namespace PSBicep.Core.Services;

public class BicepBuilder
{
    private readonly JoinableTaskFactory joinableTaskFactory;
    private readonly BicepCompiler compiler;
    private readonly DiagnosticLogger diagnosticLogger;

    public BicepBuilder(
        JoinableTaskFactory joinableTaskFactory,
        BicepCompiler compiler,
        DiagnosticLogger diagnosticLogger)
    {
        this.joinableTaskFactory = joinableTaskFactory;
        this.compiler = compiler;
        this.diagnosticLogger = diagnosticLogger;
    }

    public BuildResult Build(string bicepPath, string usingPath = "", bool noRestore = false) =>
        joinableTaskFactory.Run(() => BuildAsync(bicepPath, usingPath, noRestore));

    public async Task<BuildResult> BuildAsync(string bicepPath, string usingPath = "", bool noRestore = false)
    {
        var inputPath = PathHelper.ResolvePath(bicepPath);
        var inputUri = PathHelper.FilePathToFileUrl(inputPath);

        if (!IsBicepFile(inputUri) && !IsBicepparamsFile(inputUri))
        {
            throw new InvalidOperationException($"Input file '{inputPath}' must have a .bicep or .bicepparam extension.");
        }

        var compilation = await compiler.CreateCompilation(inputUri, skipRestore: noRestore);

        var summary = diagnosticLogger.LogDiagnostics(compilation);

        if (summary.HasErrors)
        {
            throw new InvalidOperationException($"Failed to compile file: {inputPath}");
        }

        var fileKind = compilation.SourceFileGrouping.EntryPoint.FileKind;

        switch (fileKind)
        {
            case BicepSourceFileKind.BicepFile:
                var template = compilation.Emitter.Template();
                return new BuildResult(
                    Parameters: null,
                    TemplateSpecId: null,
                    Template: template.Template,
                    SourceMap: template.SourceMap);
            case BicepSourceFileKind.ParamsFile:
                var parameters = compilation.Emitter.Parameters();
                return new BuildResult(
                    Parameters: parameters.Parameters,
                    TemplateSpecId: parameters.TemplateSpecId,
                    Template: parameters.Template?.Template,
                    SourceMap: parameters.Template?.SourceMap);
            default:
                throw new NotImplementedException($"Unexpected file kind '{fileKind}'");
        }
    }

    private static bool IsBicepFile(Uri inputUri) => PathHelper.HasBicepExtension(inputUri);
    private static bool IsBicepparamsFile(Uri inputUri) => PathHelper.HasBicepparamsExtension(inputUri);
}