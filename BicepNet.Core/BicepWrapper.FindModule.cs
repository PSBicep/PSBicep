using Azure;
using Azure.Containers.ContainerRegistry;
using Bicep.Core.FileSystem;
using Bicep.Core.Registry;
using Bicep.Core.Tracing;
using Bicep.Core.Workspaces;
using BicepNet.Core.Models;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;

namespace BicepNet.Core;

public partial class BicepWrapper
{
    /// <summary>
    /// Find modules in registries by using a specific endpoints or by seraching a bicep file.
    /// </summary>
    public IList<BicepRepository> FindModules(string inputString, bool isRegistryEndpoint)
    {
        List<string> endpoints = [];

        // If a registry is specified, only add that
        if (isRegistryEndpoint)
        {
            endpoints.Add(inputString);
        }
        else // Otherwise search a file for valid references
        {
            logger?.LogInformation("Searching file {inputString} for endpoints", inputString);
            var inputUri = PathHelper.FilePathToFileUrl(inputString);

            var sourceFileGrouping = SourceFileGroupingBuilder.Build(
               fileResolver,
               moduleDispatcher,
               configurationManager,
               workspace,
               inputUri,
               featureProviderFactory,
               false);
            var moduleReferences = ArtifactHelper.GetValidArtifactReferences(sourceFileGrouping.GetArtifactsToRestore());

            // FullyQualifiedReferences are already unwrapped from potential local aliases
            var fullReferences = moduleReferences.Select(m => m.FullyQualifiedReference);
            // Create objects with all module references grouped by endpoint
            // Format endpoint from "br:example.azurecr.io/repository/template:tag" to "example.azurecr.io"
            endpoints.AddRange(fullReferences.Select(r => r[3..].Split('/').First()).Distinct());
        }

        return FindModulesByEndpoints(endpoints);
    }

    /// <summary>
    /// Find modules in registries by using endpoints restored to cache.
    /// </summary>
    public IList<BicepRepository> FindModules()
    {
        List<string> endpoints = [];

        logger?.LogInformation("Searching cache {OciCachePath} for endpoints", OciCachePath);
        var directories = Directory.GetDirectories(OciCachePath);
        foreach (var directoryPath in directories)
        {
            var directoryName = Path.GetFileName(directoryPath);
            if(directoryName != "mcr.microsoft.com") {
                logger?.LogInformation("Found endpoint {directoryName}", directoryName);
                endpoints.Add(directoryName);
            }
        }

        return FindModulesByEndpoints(endpoints);
    }

    private List<BicepRepository> FindModulesByEndpoints(IList<string> endpoints)
    {
        if (endpoints.Count > 0)
        {
            logger?.LogInformation("Found endpoints:\n{joinedEndpoints}", string.Join("\n", endpoints));
        }
        else
        {
            logger?.LogInformation("Found no endpoints in file");
        }

        // Create credential and options
        var cred = tokenCredentialFactory.CreateChain(configuration.Cloud.CredentialPrecedence, null, configuration.Cloud.ActiveDirectoryAuthorityUri);
        var options = new ContainerRegistryClientOptions();
        options.Diagnostics.ApplySharedContainerRegistrySettings();
        options.Audience = new ContainerRegistryAudience(configuration.Cloud.ResourceManagerAudience);

        var repos = new List<BicepRepository>();
        foreach (var endpoint in endpoints.Distinct())
        {
            try
            {
                logger?.LogInformation("Searching endpoint {endpoint}", endpoint);
                var client = new ContainerRegistryClient(new Uri($"https://{endpoint}"), cred, options);
                var repositoryNames = client.GetRepositoryNames();

                foreach (var repositoryName in repositoryNames)
                {
                    logger?.LogInformation("Searching module {repositoryName}", repositoryName);

                    // Create model repository to output
                    BicepRepository bicepRepository = new(endpoint, repositoryName);

                    var repository = client.GetRepository(repositoryName);
                    var repositoryManifests = repository.GetAllManifestProperties();

                    var manifestCount = repositoryManifests.Count();
                    logger?.LogInformation("{manifestCount} manifest(s) found.", manifestCount);

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
                                logger?.LogInformation("Found tag \"{tag.Name}\"", tag.Name);
                                tagList.Add(new BicepRepositoryModuleTag(
                                    name: tag.Name,
                                    digest: tag.Digest,
                                    updatedOn: tag.LastUpdatedOn,
                                    createdOn: tag.CreatedOn,
                                    target: $"br:{endpoint}/{repositoryName}:{tag.Name}"
                                ));
                            }
                        } // When there are no tags, we cannot enumerate null - disregard this error and continue
                        catch (InvalidOperationException ex) when (ex.TargetSite?.Name == "EnumerateArray" || ex.TargetSite?.Name == "ThrowJsonElementWrongTypeException") {
                            logger?.LogInformation("No tags found for manifest with digest {moduleManifest.Digest}", moduleManifest.Digest);
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
