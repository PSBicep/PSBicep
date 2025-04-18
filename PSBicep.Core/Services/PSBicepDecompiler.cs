using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Bicep.Core.FileSystem;
using Bicep.Decompiler;
using Bicep.IO.Abstraction;
using Microsoft.VisualStudio.Threading;
using PSBicep.Core.Models;

namespace PSBicep.Core.Services;

public class PSBicepDecompiler
{
    private readonly JoinableTaskFactory _joinableTaskFactory;
    private readonly IFileResolver _fileResolver;
    private readonly Bicep.Decompiler.BicepDecompiler _decompiler;

    public PSBicepDecompiler(
        JoinableTaskFactory joinableTaskFactory,
        IFileResolver fileResolver,
        Bicep.Decompiler.BicepDecompiler decompiler)
    {
        _joinableTaskFactory = joinableTaskFactory;
        _fileResolver = fileResolver;
        _decompiler = decompiler;
    }

    public IDictionary<string, string> Decompile(string templatePath) =>
        _joinableTaskFactory.Run(() => DecompileAsync(templatePath));

    public async Task<IDictionary<string, string>> DecompileAsync(string templatePath)
    {
        var inputPath = PathHelper.ResolvePath(templatePath);
        var inputUri = PathHelper.FilePathToFileUrl(inputPath);

        if (!_fileResolver.TryRead(inputUri).IsSuccess(out var jsonContent))
        {
            throw new InvalidOperationException($"Failed to read {inputUri}");
        }

        var template = new Dictionary<string, string>();
        var decompilation = await _decompiler.Decompile(PathHelper.ChangeToBicepExtension(inputUri), jsonContent);

        foreach (var (fileUri, bicepOutput) in decompilation.FilesToSave)
        {
            template.Add(fileUri.LocalPath, bicepOutput);
        }

        return template;
    }
}