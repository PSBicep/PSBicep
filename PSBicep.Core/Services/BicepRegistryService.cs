using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Azure;
using Azure.Containers.ContainerRegistry;
using Bicep.Core;
using Bicep.Core.Configuration;
using Bicep.Core.Diagnostics;
using Bicep.Core.Exceptions;
using Bicep.Core.FileSystem;
using Bicep.Core.Registry;
using Bicep.Core.SourceGraph;
using Bicep.Core.SourceLink;
using Bicep.Core.Tracing;
using Bicep.IO.Abstraction;
using Microsoft.Extensions.Logging;
using Microsoft.VisualStudio.Threading;
using PSBicep.Core.Authentication;
using PSBicep.Core.Configuration;
using PSBicep.Core.Logging;
using PSBicep.Core.Models;

namespace PSBicep.Core.Services;

/// <summary>
/// Service for interacting with Azure Bicep registries - providing functionality for
/// publishing modules to registry and discovering available modules in registries.
/// </summary>
public class BicepRegistryService
{
    private readonly JoinableTaskFactory joinableTaskFactory;
    private readonly BicepCompiler compiler;
    private readonly DiagnosticLogger diagnosticLogger;
    private readonly IModuleDispatcher moduleDispatcher;
    private readonly IFileExplorer fileExplorer;
    private readonly BicepTokenCredentialFactory tokenCredentialFactory;
    private readonly BicepConfigurationManager configurationManager;

    /// <summary>
    /// Using a fake URI to satify the SetToken method.
    /// Since tokens are handled by the PowerShell code we will always get a valid token
    /// and don't currently support refreshing it so URI will never be used.
    /// </summary>
    private const string fakeAuthUri = "https://fakeauthuri.com/";

    public BicepRegistryService(
        JoinableTaskFactory joinableTaskFactory,
        BicepCompiler compiler,
        DiagnosticLogger diagnosticLogger,
        IModuleDispatcher moduleDispatcher,
        IFileExplorer fileExplorer,
        BicepTokenCredentialFactory tokenCredentialFactory,
        BicepConfigurationManager configurationManager)
    {
        this.joinableTaskFactory = joinableTaskFactory;
        this.compiler = compiler;
        this.diagnosticLogger = diagnosticLogger;
        this.moduleDispatcher = moduleDispatcher;
        this.fileExplorer = fileExplorer;
        this.tokenCredentialFactory = tokenCredentialFactory;
        this.configurationManager = configurationManager;
    }

    public void SetAuthentication(string token) =>
        tokenCredentialFactory.SetToken(new Uri(fakeAuthUri), token);

    /// <summary>
    /// Publishes a Bicep file to an Azure Container Registry
    /// </summary>
    /// <param name="inputFilePath">Path to the Bicep file to publish</param>
    /// <param name="targetModuleReference">Target module reference in format 'br:registry/repository:tag'</param>
    /// <param name="token">Authentication token for the registry</param>
    /// <param name="documentationUri">Optional URI to module documentation</param>
    /// <param name="publishSource">Include the source code when publishing</param>
    /// <param name="overwriteIfExists">Overwrite the module if it already exists</param>
    public void Publish(string inputFilePath, string targetModuleReference, string token, string? documentationUri, bool publishSource = false, bool overwriteIfExists = false) =>
        joinableTaskFactory.Run(() => PublishAsync(inputFilePath, targetModuleReference, token, documentationUri, publishSource, overwriteIfExists));

    /// <summary>
    /// Publishes a Bicep file to an Azure Container Registry asynchronously
    /// </summary>
    /// <param name="inputFilePath">Path to the Bicep file to publish</param>
    /// <param name="targetModuleReference">Target module reference in format 'br:registry/repository:tag'</param>
    /// <param name="token">Authentication token for the registry</param>
    /// <param name="documentationUri">Optional URI to module documentation</param>
    /// <param name="publishSource">Whether to include the source code when publishing</param>
    /// <param name="overwriteIfExists">Whether to overwrite the module if it already exists</param>
    /// <param name="skipRestore">Whether to skip restoring referenced modules before compilation</param>
    /// <exception cref="BicepException">Thrown when the module cannot be compiled or published</exception>
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
            throw new BicepException($"The Bicep file {inputFilePath} could not be compiled.");
        }

        if (result.Template is not { } compiledArmTemplate)
        {
            // can't publish if we can't compile
            throw new BicepException($"The Bicep file {inputFilePath} could not be compiled.");
        }

        // Handle publishing source
        SourceArchive? sourceArchive = null;
        if (publishSource)
        {
            sourceArchive = SourceArchive.CreateFrom(compilation.SourceFileGrouping);
            diagnosticLogger.Log(LogLevel.Trace, "Publishing Bicep module with source");
        }

        var preposition = sourceArchive is { } ? "with" : "without";
        diagnosticLogger.Log(LogLevel.Trace, "Publishing Bicep module {0} source", preposition);
        var sourcesPayload = sourceArchive is { } ? sourceArchive.PackIntoBinaryData() : null;
        await PublishModuleAsync(moduleReference, BinaryData.FromString(compiledArmTemplate), sourcesPayload, documentationUri, overwriteIfExists);

    }

    /// <summary>
    /// Publishes a module to an Azure Container Registry
    /// </summary>
    /// <remarks>copied from PublishCommand.cs in Bicep CLI</remarks>
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

    /// <summary>
    /// Validates a module reference and returns the artifact reference
    /// </summary>
    /// <remarks>copied from PublishCommand.cs in Bicep CLI</remarks>
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

    /// <summary>
    /// Find modules in registries by using a specific endpoint or by searching through a Bicep file
    /// </summary>
    /// <param name="path">Either the registry endpoint or path to a Bicep file to analyze</param>
    /// <param name="isRegistryEndpoint">Whether the path is a registry endpoint</param>
    /// <param name="configurationPath">Path to the Bicep configuration used for operations</param>
    /// <returns>List of repositories found in the registries</returns>
    public IList<BicepRepository> FindModules(string path, bool isRegistryEndpoint, string configurationPath)
    {
        List<string> endpoints = [];
        RootConfiguration configuration = configurationManager.GetConfiguration(PathHelper.FilePathToFileUrl(configurationPath));

        // If a registry is specified, only add that
        if (isRegistryEndpoint)
        {
            endpoints.Add(path);
        }
        else // Otherwise search a file for valid references
        {
            diagnosticLogger.Log(LogLevel.Trace, "Searching file {path} for endpoints", path);
            var inputUri = PathHelper.FilePathToFileUrl(path);
            var workspace = new Workspace();
            var compilation = joinableTaskFactory.Run(async () =>
            {
                return await compiler.CreateCompilation(inputUri, skipRestore: true);
            });
            var sourceFileGrouping = compilation.SourceFileGrouping;

            var moduleReferences = ArtifactHelper.GetValidArtifactReferences(sourceFileGrouping.GetArtifactsToRestore());

            // FullyQualifiedReferences are already unwrapped from potential local aliases
            var fullReferences = moduleReferences.Select(m => m.FullyQualifiedReference);
            // Create objects with all module references grouped by endpoint
            // Format endpoint from "br:example.azurecr.io/repository/template:tag" to "example.azurecr.io"
            endpoints.AddRange(fullReferences.Select(r => r[3..].Split('/').First()).Distinct());
        }

        return FindModulesByEndpoints(endpoints, configuration);
    }

    /// <summary>
    /// Find modules in all registries available in the local module cache
    /// </summary>
    /// <returns>List of repositories found in the cached registries</returns>
    public IList<BicepRepository> FindModules()
    {
        List<string> endpoints = [];

        var ociCachePath = Path.Combine(GetCachePath(""), "br");
        var configuration = configurationManager.GetConfiguration(new Uri("inmemory:///main.bicp"));
        diagnosticLogger.Log(LogLevel.Trace, "Searching cache {ociCachePath} for endpoints", ociCachePath);
        var directories = Directory.GetDirectories(ociCachePath);
        foreach (var directoryPath in directories)
        {
            var directoryName = Path.GetFileName(directoryPath);
            if (directoryName != "mcr.microsoft.com")
            {
                diagnosticLogger.Log(LogLevel.Trace, "Found endpoint {directoryName}", directoryName);
                endpoints.Add(directoryName);
            }
        }

        return FindModulesByEndpoints(endpoints, configuration);
    }

    /// <summary>
    /// Gets the cache path for Bicep modules based on configuration
    /// </summary>
    /// <param name="path">Path to use for obtaining configuration</param>
    /// <returns>The cache root directory path</returns>
    private string GetCachePath(string path)
    {
        return configurationManager.GetConfiguration(PathHelper.FilePathToFileUrl(path)).CacheRootDirectory!;
    }

    /// <summary>
    /// Find modules in registries by connecting to the specified endpoints
    /// </summary>
    /// <param name="endpoints">Collection of registry endpoints to search, in fqdn format</param>
    /// <param name="configuration">Bicep root configuration for authentication</param>
    /// <returns>List of repositories found in the specified endpoints</returns>
    private List<BicepRepository> FindModulesByEndpoints(IList<string> endpoints, RootConfiguration configuration)
    {
        if (endpoints.Count > 0)
        {
            diagnosticLogger.Log(LogLevel.Trace, "Found endpoints:\n{joinedEndpoints}", string.Join("\n", endpoints));
        }
        else
        {
            diagnosticLogger.Log(LogLevel.Trace, "Found no endpoints in file");
        }

        // Create credential and options
        var cred = tokenCredentialFactory.Credential;
        var options = new ContainerRegistryClientOptions();
        options.Diagnostics.ApplySharedContainerRegistrySettings();
        options.Audience = new ContainerRegistryAudience(configuration.Cloud.ResourceManagerAudience);

        var repos = new List<BicepRepository>();
        foreach (var endpoint in endpoints.Distinct())
        {
            try
            {
                diagnosticLogger.Log(LogLevel.Trace, "Searching endpoint {endpoint}", endpoint);
                var client = new ContainerRegistryClient(new Uri($"https://{endpoint}"), cred, options);
                var repositoryNames = client.GetRepositoryNames();

                foreach (var repositoryName in repositoryNames)
                {
                    diagnosticLogger.Log(LogLevel.Trace, "Searching module {repositoryName}", repositoryName);

                    // Create model repository to output
                    BicepRepository bicepRepository = new(endpoint, repositoryName);

                    var repository = client.GetRepository(repositoryName);
                    var repositoryManifests = repository.GetAllManifestProperties();

                    var manifestCount = repositoryManifests.Count();
                    diagnosticLogger.Log(LogLevel.Trace, "{manifestCount} manifest(s) found.", manifestCount);

                    foreach (var moduleManifest in repositoryManifests)
                    {
                        var artifact = repository.GetArtifact(moduleManifest.Digest);
                        var tags = artifact.GetTagPropertiesCollection();

                        List<BicepRepositoryModuleTag> tagList = [];
                        // All artifacts don't have tags, but the tags variable will not be null because of the pageable
                        // This means we can't compare null
                        try
                        {
                            foreach (var tag in tags)
                            {
                                diagnosticLogger.Log(LogLevel.Trace, "Found tag \"{tag.Name}\"", tag.Name);
                                tagList.Add(new BicepRepositoryModuleTag(
                                    name: tag.Name,
                                    digest: tag.Digest,
                                    updatedOn: tag.LastUpdatedOn,
                                    createdOn: tag.CreatedOn,
                                    target: $"br:{endpoint}/{repositoryName}:{tag.Name}"
                                ));
                            }
                        } // When there are no tags, we cannot enumerate null - disregard this error and continue
                        catch (InvalidOperationException ex) when (ex.TargetSite?.Name == "EnumerateArray" || ex.TargetSite?.Name == "ThrowJsonElementWrongTypeException")
                        {
                            diagnosticLogger.Log(LogLevel.Trace, "No tags found for manifest with digest {moduleManifest.Digest}", moduleManifest.Digest);
                        }

                        var bicepModule = new BicepRepositoryModule(
                            digest: moduleManifest.Digest,
                            repository: repositoryName,
                            tags: tagList,
                            createdOn: moduleManifest.CreatedOn,
                            updatedOn: moduleManifest.LastUpdatedOn
                        );
                        bicepRepository.ModuleVersions.Add(bicepModule);
                    }

                    bicepRepository.ModuleVersions = [.. bicepRepository.ModuleVersions.OrderByDescending(t => t.UpdatedOn)];

                    repos.Add(bicepRepository);
                }
            }
            catch (RequestFailedException ex)
            {
                switch (ex.Status)
                {
                    case 401:
                        diagnosticLogger.Log(LogLevel.Warning, "The credentials provided are not authorized to the following registry: {endpoint}", endpoint);
                        break;
                    default:
                        diagnosticLogger.Log(LogLevel.Error, ex, "Could not get modules from endpoint {endpoint}!", endpoint);
                        break;
                }
            }
            catch (AggregateException ex)
            {
                if (ex.InnerException != null)
                {
                    diagnosticLogger.Log(LogLevel.Warning, "{message}", ex.InnerException.Message);
                }
                else
                {
                    diagnosticLogger.Log(LogLevel.Error, ex, "Could not get modules from endpoint {endpoint}!", endpoint);
                }
            }
            catch (Exception ex)
            {
                diagnosticLogger.Log(LogLevel.Error, ex, "Could not get modules from endpoint {endpoint}!", endpoint);
            }
        }

        return repos;
    }
}