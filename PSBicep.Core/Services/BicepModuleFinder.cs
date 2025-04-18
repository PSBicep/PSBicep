using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using Azure;
using Azure.Containers.ContainerRegistry;
using Bicep.Core;
using Bicep.Core.Configuration;
using Bicep.Core.FileSystem;
using Bicep.Core.Registry;
using Bicep.Core.SourceGraph;
using Bicep.Core.Tracing;
using Microsoft.Extensions.Logging;
using Microsoft.VisualStudio.Threading;
using PSBicep.Core.Authentication;
using PSBicep.Core.Configuration;
using PSBicep.Core.Models;

namespace PSBicep.Core.Services;

public class BicepModuleFinder
{
    private readonly JoinableTaskFactory joinableTaskFactory;
    private readonly BicepCompiler compiler;
    private readonly BicepConfigurationManager configurationManager;
    private readonly ILogger logger;
    private readonly BicepTokenCredentialFactory tokenCredentialFactory;

    public BicepModuleFinder(
        JoinableTaskFactory joinableTaskFactory,
        BicepCompiler compiler,
        BicepConfigurationManager configurationManager,
        ILogger logger,
        BicepTokenCredentialFactory tokenCredentialFactory)
    {
        this.joinableTaskFactory = joinableTaskFactory;
        this.compiler = compiler;
        this.configurationManager = configurationManager;
        this.logger = logger;
        this.tokenCredentialFactory = tokenCredentialFactory;
    }

    /// <summary>
    /// Find modules in registries by using a specific endpoints or by seraching a bicep file.
    /// </summary>
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
            logger?.LogTrace("Searching file {inputString} for endpoints", path);
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
    /// Find modules in registries by using endpoints restored to cache.
    /// </summary>
    public IList<BicepRepository> FindModules()
    {
        List<string> endpoints = [];

        var ociCachePath = Path.Combine(GetCachePath(""), "br");
        var configuration = configurationManager.GetConfiguration(new Uri("inmemory:///main.bicp"));
        logger?.LogTrace("Searching cache {ociCachePath} for endpoints", ociCachePath);
        var directories = Directory.GetDirectories(ociCachePath);
        foreach (var directoryPath in directories)
        {
            var directoryName = Path.GetFileName(directoryPath);
            if (directoryName != "mcr.microsoft.com")
            {
                logger?.LogTrace("Found endpoint {directoryName}", directoryName);
                endpoints.Add(directoryName);
            }
        }

        return FindModulesByEndpoints(endpoints, configuration);
    }

    private string GetCachePath(string path)
    {
        return configurationManager.GetConfiguration(PathHelper.FilePathToFileUrl(path)).CacheRootDirectory!;
    }

    private List<BicepRepository> FindModulesByEndpoints(IList<string> endpoints, RootConfiguration configuration)
    {
        if (endpoints.Count > 0)
        {
            logger?.LogTrace("Found endpoints:\n{joinedEndpoints}", string.Join("\n", endpoints));
        }
        else
        {
            logger?.LogTrace("Found no endpoints in file");
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
                logger?.LogTrace("Searching endpoint {endpoint}", endpoint);
                var client = new ContainerRegistryClient(new Uri($"https://{endpoint}"), cred, options);
                var repositoryNames = client.GetRepositoryNames();

                foreach (var repositoryName in repositoryNames)
                {
                    logger?.LogTrace("Searching module {repositoryName}", repositoryName);

                    // Create model repository to output
                    BicepRepository bicepRepository = new(endpoint, repositoryName);

                    var repository = client.GetRepository(repositoryName);
                    var repositoryManifests = repository.GetAllManifestProperties();

                    var manifestCount = repositoryManifests.Count();
                    logger?.LogTrace("{manifestCount} manifest(s) found.", manifestCount);

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
                                logger?.LogTrace("Found tag \"{tag.Name}\"", tag.Name);
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
                            logger?.LogTrace("No tags found for manifest with digest {moduleManifest.Digest}", moduleManifest.Digest);
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
                        logger?.LogWarning("The credentials provided are not authorized to the following registry: {endpoint}", endpoint);
                        break;
                    default:
                        logger?.LogError(ex, "Could not get modules from endpoint {endpoint}!", endpoint);
                        break;
                }
            }
            catch (AggregateException ex)
            {
                if (ex.InnerException != null)
                {
                    logger?.LogWarning("{message}", ex.InnerException.Message);
                }
                else
                {
                    logger?.LogError(ex, "Could not get modules from endpoint {endpoint}!", endpoint);
                }
            }
            catch (Exception ex)
            {
                logger?.LogError(ex, "Could not get modules from endpoint {endpoint}!", endpoint);
            }
        }

        return repos;
    }
}