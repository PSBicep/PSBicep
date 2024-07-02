using Bicep.Core;
using Bicep.Core.Diagnostics;
using Bicep.Core.FileSystem;
using Bicep.Core.Navigation;
using Bicep.Core.Registry;
using Bicep.Core.Syntax;
using Bicep.Core.Workspaces;
using Microsoft.Extensions.Logging;
using System.Collections.Generic;
using System.Collections.Immutable;
using System.Linq;
using System.Threading.Tasks;

namespace BicepNet.Core;

public partial class BicepWrapper
{
    public void Restore(string inputFilePath, bool forceModulesRestore = false) => joinableTaskFactory.Run(() => RestoreAsync(inputFilePath, forceModulesRestore));

    public async Task RestoreAsync(string inputFilePath, bool forceModulesRestore = false)
    {
        logger?.LogInformation("Restoring external modules to local cache for file {inputFilePath}", inputFilePath);
        var inputPath = PathHelper.ResolvePath(inputFilePath);
        var inputUri = PathHelper.FilePathToFileUrl(inputPath);

        var bicepCompiler = new BicepCompiler(featureProviderFactory, environment, namespaceProvider, configurationManager, bicepAnalyzer, fileResolver, moduleDispatcher);
        var compilation = await bicepCompiler.CreateCompilation(inputUri, workspace, true, forceModulesRestore);

        var originalModulesToRestore = compilation.SourceFileGrouping.GetArtifactsToRestore().ToImmutableHashSet();

        // RestoreModules() does a distinct but we'll do it also to prevent duplicates in processing and logging
        var modulesToRestoreReferences = ArtifactHelper.GetValidArtifactReferences(originalModulesToRestore)
            .Distinct()
            .OrderBy(key => key.FullyQualifiedReference);

        // restore is supposed to only restore the module references that are syntactically valid
        await moduleDispatcher.RestoreArtifacts(modulesToRestoreReferences, forceModulesRestore);

        // update the errors based on restore status
        var sourceFileGrouping = SourceFileGroupingBuilder.Rebuild(
            fileResolver, 
            featureProviderFactory, 
            moduleDispatcher, 
            configurationManager, 
            workspace, 
            compilation.SourceFileGrouping);

        LogDiagnostics(compilation);

        if (modulesToRestoreReferences.Any())
        {
            logger?.LogInformation("Successfully restored modules in {inputFilePath}", inputFilePath);
        }
        else
        {
            logger?.LogInformation("No new modules to restore in {inputFilePath}", inputFilePath);
        }
    }
}
