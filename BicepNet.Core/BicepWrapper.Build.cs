using Bicep.Core.Emit;
using Bicep.Core.FileSystem;
using Bicep.Core.Semantics;
using Bicep.Core.Workspaces;
using System;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;

namespace BicepNet.Core;

public partial class BicepWrapper
{
    public IList<string> Build(string bicepPath, string usingPath = "", bool noRestore = false) => joinableTaskFactory.Run(() => BuildAsync(bicepPath, usingPath, noRestore));

    public async Task<IList<string>> BuildAsync(string bicepPath, string usingPath = "", bool noRestore = false)
    {
        var inputPath = PathHelper.ResolvePath(bicepPath);
        var inputUri = PathHelper.FilePathToFileUrl(inputPath);

        if (!IsBicepFile(inputUri) && !IsBicepparamsFile(inputUri))
        {
            throw new InvalidOperationException($"Input file '{inputPath}' must have a .bicep or .bicepparam extension.");
        }

        var compilation = await compiler.CreateCompilation(inputUri, skipRestore: noRestore);

        var summary = LogDiagnostics(compilation);

        if (diagnosticLogger is not null && summary.HasErrors)
        {
            throw new InvalidOperationException($"Failed to compile file: {inputPath}");
        }

        var fileKind = compilation.SourceFileGrouping.EntryPoint.FileKind;
            
        var stream = new MemoryStream();
        EmitResult emitresult = fileKind switch
        {
            BicepSourceFileKind.BicepFile => new TemplateEmitter(compilation.GetEntrypointSemanticModel()).Emit(stream),
            BicepSourceFileKind.ParamsFile => EmitParamsFile(compilation, usingPath, stream),
            _ => throw new NotImplementedException($"Unexpected file kind '{fileKind}'"),
        };

        if (emitresult.Status != EmitStatus.Succeeded)
        {
            throw new InvalidOperationException($"Failed to emit bicep with error: ${emitresult.Status}");
        }

        stream.Position = 0;
        using var reader = new StreamReader(stream);
        var result = await reader.ReadToEndAsync();

        var template = new List<string>
        {
            result
        };
        return template;
    }

    private static bool IsBicepFile(Uri inputUri) => PathHelper.HasBicepExtension(inputUri);
    private static bool IsBicepparamsFile(Uri inputUri) => PathHelper.HasBicepparamsExtension(inputUri);

    private static EmitResult EmitParamsFile(Compilation compilation, string usingPath, Stream stream)
    {
        var bicepPath = PathHelper.ResolvePath(usingPath);
        var paramsSemanticModel = compilation.GetEntrypointSemanticModel();
        if (usingPath != "" && paramsSemanticModel.Root.TryGetBicepFileSemanticModelViaUsing().IsSuccess(out var usingModel))
        {
            if (usingModel is not SemanticModel bicepSemanticModel)
            {
                throw new InvalidOperationException($"Bicep file {bicepPath} provided can only be used if the Bicep parameters \"using\" declaration refers to a Bicep file on disk.");
            }

            var bicepFileUsingPathUri = bicepSemanticModel.Root.FileUri;

            if (bicepPath is not null && !bicepFileUsingPathUri.Equals(PathHelper.FilePathToFileUrl(bicepPath)))
            {
                throw new InvalidOperationException($"Bicep file {bicepPath} provided with templatePath option doesn't match the Bicep file {bicepSemanticModel?.Root.Name} referenced by the using declaration in the parameters file");
            }

        }
        var emitter = new ParametersEmitter(paramsSemanticModel);
        return emitter.Emit(stream);
    }
}
