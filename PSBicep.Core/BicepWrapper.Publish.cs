using System;
using System.Diagnostics;
using System.IO;
using System.Threading.Tasks;
using Bicep.Core.Diagnostics;
using Bicep.Core.Exceptions;
using Bicep.Core.FileSystem;
using Bicep.Core.Registry;
using Bicep.Core.SourceLink;
using Bicep.IO.Abstraction;
using PSBicep.Core.Logging;

namespace PSBicep.Core;

public partial class BicepWrapper
{
    public void Publish(string inputFilePath, string targetModuleReference, string token, string? documentationUri, bool publishSource = false, bool overwriteIfExists = false) =>
        joinableTaskFactory.Run(() => PublishAsync(inputFilePath, targetModuleReference, token, documentationUri, publishSource, overwriteIfExists));

    public async Task PublishAsync(string inputFilePath, string targetModuleReference, string token, string? documentationUri, bool publishSource = false, bool overwriteIfExists = false, bool skipRestore = false)
    {
        SetAuthentication(token);

        var inputPath = PathHelper.ResolvePath(inputFilePath);
        var inputUri = PathHelper.FilePathToFileUrl(inputPath);
        var moduleReference = ValidateReference(targetModuleReference, inputUri);

        if (PathHelper.HasArmTemplateLikeExtension(inputUri))
        {
            if (publishSource)
            {
                throw new BicepException("Cannot publish with source when the target is an ARM template file.");
            }
            // Publishing an ARM template file.
            using var armTemplateStream = fileExplorer.GetFile(IOUri.FromLocalFilePath(inputPath)).OpenRead();
            await this.PublishModuleAsync(moduleReference, BinaryData.FromStream(armTemplateStream), null, documentationUri, overwriteIfExists);
            return;
        }

        var compilation = await compiler.CreateCompilation(inputUri, skipRestore: skipRestore);
        var result = compilation.Emitter.Template();

        var summary = diagnosticLogger.LogDiagnostics(DiagnosticOptions.Default, result.Diagnostics);
        if (summary.HasErrors)
        {
            throw new BicepException($"The Bicep file {inputPath} could not be compiled.");
        }

        if (result.Template is not { } compiledArmTemplate)
        {
            // can't publish if we can't compile
            throw new BicepException($"The Bicep file {inputPath} could not be compiled.");
        }

        // Handle publishing source
        Stream? sourcesStream = null;
        if (publishSource)
        {
            sourcesStream = SourceArchive.PackSourcesIntoStream(moduleDispatcher, compilation.SourceFileGrouping, compilation.GetEntrypointSemanticModel().Features.CacheRootDirectory);
            Trace.WriteLine("Publishing Bicep module with source");
        }

        using (sourcesStream)
        {
            Trace.WriteLine(sourcesStream is { } ? "Publishing Bicep module with source" : "Publishing Bicep module without source");
            var sourcesPayload = sourcesStream is { } ? BinaryData.FromStream(sourcesStream) : null;
            await PublishModuleAsync(moduleReference, BinaryData.FromString(compiledArmTemplate), sourcesPayload, documentationUri, overwriteIfExists);
        }

    }

    // copied from PublishCommand.cs
    private async Task PublishModuleAsync(ArtifactReference target, BinaryData compiledArmTemplate, BinaryData? bicepSources, string? documentationUri, bool overwriteIfExists)
    {
        try
        {
            // If we don't want to overwrite, ensure module doesn't exist
            if (!overwriteIfExists && await this.moduleDispatcher.CheckModuleExists(target))
            {
                throw new BicepException($"The module \"{target.FullyQualifiedReference}\" already exists in registry. Use --force to overwrite the existing module.");
            }
            await this.moduleDispatcher.PublishModule(target, compiledArmTemplate, bicepSources, documentationUri);
        }
        catch (ExternalArtifactException exception)
        {
            throw new BicepException($"Unable to publish module \"{target.FullyQualifiedReference}\": {exception.Message}");
        }
    }

    private ArtifactReference ValidateReference(string targetModuleReference, Uri targetModuleUri)
    {
        var dummyReferencingFile = compiler.SourceFileFactory.CreateBicepFile(targetModuleUri, string.Empty);

        if (!this.moduleDispatcher.TryGetArtifactReference(dummyReferencingFile, ArtifactType.Module, targetModuleReference).IsSuccess(out var moduleReference, out var failureBuilder))
        {
            // TODO: We should probably clean up the dispatcher contract so this sort of thing isn't necessary (unless we change how target module is set in this command)
            var message = failureBuilder(DiagnosticBuilder.ForDocumentStart()).Message;

            throw new BicepException(message);
        }

        if (!this.moduleDispatcher.GetRegistryCapabilities(ArtifactType.Module, moduleReference).HasFlag(RegistryCapabilities.Publish))
        {
            throw new BicepException($"The specified module target \"{targetModuleReference}\" is not supported.");
        }

        return moduleReference;
    }
}
