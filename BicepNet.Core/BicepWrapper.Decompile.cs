using Bicep.Core.FileSystem;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace BicepNet.Core;

public partial class BicepWrapper
{
    public IDictionary<string, string> Decompile(string templatePath) =>
        joinableTaskFactory.Run(() => DecompileAsync(templatePath));

    public async Task<IDictionary<string, string>> DecompileAsync(string templatePath)
    {
        var inputPath = PathHelper.ResolvePath(templatePath);
        var inputUri = PathHelper.FilePathToFileUrl(inputPath);

        if (!fileResolver.TryRead(inputUri).IsSuccess(out var jsonContent))
        {
            throw new InvalidOperationException($"Failed to read {inputUri}");
        }

        var template = new Dictionary<string, string>();
        var decompilation = await decompiler.Decompile(PathHelper.ChangeToBicepExtension(inputUri), jsonContent);

        foreach (var (fileUri, bicepOutput) in decompilation.FilesToSave)
        {
            template.Add(fileUri.LocalPath, bicepOutput);
        }

        return template;
    }
}
