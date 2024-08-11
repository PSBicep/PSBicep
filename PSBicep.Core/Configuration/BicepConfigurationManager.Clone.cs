﻿using Bicep.Core;
using Bicep.Core.Configuration;
using Bicep.Core.Diagnostics;
using Bicep.Core.Extensions;
using Bicep.Core.FileSystem;
using Bicep.Core.Json;
using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.IO;
using System.IO.Abstractions;
using System.Security;
using System.Text.Json;

namespace PSBicep.Core.Configuration;

// This is a full copy of Bicep.Core.Configuration.ConfigurationManager where only GetDefaultConfiguration() is removed
// We have implemented our own GetDefaultConfiguration() instead
public partial class BicepConfigurationManager(IFileSystem fileSystem) : IConfigurationManager
{
    private readonly ConcurrentDictionary<Uri, (RootConfiguration? config, DiagnosticBuilder.DiagnosticBuilderDelegate? loadError)> configFileUriToLoadedConfigCache = new();
    private readonly ConcurrentDictionary<Uri, ConfigLookupResult> templateUriToConfigUriCache = new();
    private readonly IFileSystem fileSystem = fileSystem;

    public RootConfiguration GetConfiguration(Uri sourceFileUri)
    {
        var (config, diagnosticBuilders) = GetConfigurationFromCache(sourceFileUri);
        return WithLoadDiagnostics(config, diagnosticBuilders);
    }

    public void PurgeCache()
    {
        PurgeLookupCache();
        configFileUriToLoadedConfigCache.Clear();
    }

    public void PurgeLookupCache() => templateUriToConfigUriCache.Clear();

    public (RootConfiguration prevConfiguration, RootConfiguration newConfiguration)? RefreshConfigCacheEntry(Uri configUri)
    {
        (RootConfiguration, RootConfiguration)? returnVal = null;
        configFileUriToLoadedConfigCache.AddOrUpdate(configUri, LoadConfiguration, (uri, prev) =>
        {
            var reloaded = LoadConfiguration(uri);
            if (prev.config is {} prevConfig && reloaded.Item1 is {} newConfig)
            {
                returnVal = (prevConfig, newConfig);
            }
            return reloaded;
        });

        return returnVal;
    }

    public void RemoveConfigCacheEntry(Uri configUri)
    {
        if (configFileUriToLoadedConfigCache.TryRemove(configUri, out _))
        {
            // If a config file has been removed from a workspace, the lookup cache is no longer valid.
            PurgeLookupCache();
        }
    }

    private (RootConfiguration, List<DiagnosticBuilder.DiagnosticBuilderDelegate>) GetConfigurationFromCache(Uri sourceFileUri)
    {
        List<DiagnosticBuilder.DiagnosticBuilderDelegate> diagnostics = [];

        var (configFileUri, lookupDiagnostic) = templateUriToConfigUriCache.GetOrAdd(sourceFileUri, LookupConfiguration);
        if (lookupDiagnostic is not null)
        {
            diagnostics.Add(lookupDiagnostic);
        }

        if (configFileUri is not null)
        {
            var (config, loadError) = configFileUriToLoadedConfigCache.GetOrAdd(configFileUri, LoadConfiguration);
            if (loadError is not null)
            {
                diagnostics.Add(loadError);
            }

            if (config is not null)
            {
                return (config, diagnostics);
            }
        }

        return (GetDefaultConfiguration(), diagnostics);
    }

    private static RootConfiguration WithLoadDiagnostics(RootConfiguration configuration, List<DiagnosticBuilder.DiagnosticBuilderDelegate> diagnostics)
    {
        if (diagnostics.Count > 0)
        {
            return new(
                configuration.Cloud,
                configuration.ModuleAliases,
                configuration.ExtensionAliases,
                configuration.Extensions,
                configuration.ImplicitExtensions,
                configuration.Analyzers,
                configuration.CacheRootDirectory,
                configuration.ExperimentalFeaturesEnabled,
                configuration.Formatting,
                configuration.ConfigFileUri,
                diagnostics);
        }

        return configuration;
    }

    //private RootConfiguration GetDefaultConfiguration() => IConfigurationManager.GetBuiltInConfiguration();

    private (RootConfiguration?, DiagnosticBuilder.DiagnosticBuilderDelegate?) LoadConfiguration(Uri configurationUri)
    {
        try
        {
            using var stream = fileSystem.FileStream.New(configurationUri.LocalPath, FileMode.Open, FileAccess.Read);
            var element = BuiltInConfigurationElement.Merge(JsonElementFactory.CreateElementFromStream(stream));

            return (RootConfiguration.Bind(element, configurationUri), null);
        }
        catch (ConfigurationException exception)
        {
            return (null, x => x.InvalidBicepConfigFile(configurationUri.LocalPath, exception.Message));
        }
        catch (JsonException exception)
        {
            return (null, x => x.UnparsableBicepConfigFile(configurationUri.LocalPath, exception.Message));
        }
        catch (Exception exception)
        {
            return (null, x => x.UnloadableBicepConfigFile(configurationUri.LocalPath, exception.Message));
        }
    }

    private ConfigLookupResult LookupConfiguration(Uri sourceFileUri)
    {
        DiagnosticBuilder.DiagnosticBuilderDelegate? lookupDiagnostic = null;
        if (sourceFileUri.Scheme == Uri.UriSchemeFile)
        {
            string? currentDirectory = fileSystem.Path.GetDirectoryName(sourceFileUri.LocalPath);
            while (!string.IsNullOrEmpty(currentDirectory))
            {
                var configurationPath = this.fileSystem.Path.Combine(currentDirectory, LanguageConstants.BicepConfigurationFileName);

                if (this.fileSystem.File.Exists(configurationPath))
                {
                    return new(PathHelper.FilePathToFileUrl(configurationPath), lookupDiagnostic);
                }

                try
                {
                    // Catching Directory.GetParent alone because it is the only one that throws IO related exceptions.
                    // Path.Combine only throws ArgumentNullException which indicates a bug in our code.
                    // File.Exists will not throw exceptions regardless the existence of path or if the user has permissions to read the file.
                    currentDirectory = this.fileSystem.Directory.GetParent(currentDirectory)?.FullName;
                }
                catch (Exception exception) when (exception is IOException or UnauthorizedAccessException or SecurityException)
                {
                    // The exception could happen in senarios where users may not have read permission on the parent folder.
                    // We should not throw ConfigurationException in such cases since it will block compilation.
                    lookupDiagnostic = x => x.PotentialConfigDirectoryCouldNotBeScanned(currentDirectory, exception.Message);
                    break;
                }
            }
        }

        return new(null, lookupDiagnostic);
    }

    private record ConfigLookupResult(Uri? ConfigFileUri = null, DiagnosticBuilder.DiagnosticBuilderDelegate? LookupDiagnostic = null);
}
