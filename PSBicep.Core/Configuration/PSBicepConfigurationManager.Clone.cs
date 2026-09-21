using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Collections.Immutable;
using System.IO;
using System.Linq;
using System.Text.Json;
using Bicep.Core;
using Bicep.Core.Configuration;
using Bicep.Core.Diagnostics;
using Bicep.Core.Extensions;
using Bicep.Core.Json;
using Bicep.IO.Abstraction;

namespace PSBicep.Core.Configuration;

// This is a copy of Bicep.Core.Configuration.BicepConfigurationManager (Bicep v0.47) with two changes:
// - The built-in configuration is loaded from our own embedded bicepconfig.json instead of Bicep.Core's
//   (see GetDefaultConfiguration() and BuiltInConfigurationElement in PSBicepConfigurationManager.Custom.cs)
// - Directory paths are supported as input, so configuration can be looked up starting from a folder

public partial class PSBicepConfigurationManager : IBicepConfigurationManager
{
    private const int MaxChainDepth = 64;

    private static readonly DiagnosticBuilder.DiagnosticBuilderInternal ConfigDiagnosticBuilder = DiagnosticBuilder.ForDocumentStart();

    private readonly ConcurrentDictionary<IOUri, IDirectoryHandle> directoryHandleCache = new();
    private readonly ConcurrentDictionary<IDirectoryHandle, ResultWithDiagnostic<IFileHandle?>> configFileLookupCache = new();
    private readonly ConcurrentDictionary<IFileHandle, ResultWithDiagnostic<IBicepConfigurationChain>> chainCache = new();
    private readonly ConcurrentDictionary<IFileHandle, ImmutableHashSet<IOUri>> chainDependencies = new();
    private readonly IFileExplorer fileExplorer;

    public PSBicepConfigurationManager(IFileExplorer fileExplorer)
    {
        this.fileExplorer = fileExplorer;
    }

    /// <summary>
    /// Returns the effective (fully merged) configuration for the given file or directory.
    /// </summary>
    public IBicepConfiguration GetConfiguration(IOUri sourceFileUri) =>
        GetConfigurationChain(sourceFileUri).GetEffectiveConfiguration();

    public IBicepConfigurationChain GetConfigurationChain(IOUri sourceFileUri)
    {
        if (!sourceFileUri.IsFile)
        {
            return GetBuiltInChain();
        }

        var sourceDirectory = this.directoryHandleCache.GetOrAdd(sourceFileUri, GetSourceDirectory);

        if (!this.configFileLookupCache.GetOrAdd(sourceDirectory, LookupConfigurationFile).IsSuccess(out var configFileHandle, out var lookupDiagnostic))
        {
            return GetBuiltInChain(diagnostics: [lookupDiagnostic]);
        }

        if (configFileHandle is null)
        {
            return GetBuiltInChain();
        }

        if (!this.chainCache.GetOrAdd(configFileHandle, LoadChain).IsSuccess(out var chain, out var loadDiagnostic))
        {
            return GetBuiltInChain(diagnostics: [loadDiagnostic]);
        }

        return chain;
    }

    public void PurgeAllCaches()
    {
        this.directoryHandleCache.Clear();
        this.configFileLookupCache.Clear();
        this.chainCache.Clear();
        this.chainDependencies.Clear();
    }

    public void PurgeCache()
    {
        PurgeLookupCache();
        this.chainCache.Clear();
        this.chainDependencies.Clear();
    }

    public void PurgeLookupCache() => this.configFileLookupCache.Clear();

    public void PurgeChainCache()
    {
        this.chainCache.Clear();
        this.chainDependencies.Clear();
    }

    public void PurgeCacheForAffectedChains(IOUri changedFileUri)
    {
        foreach (var (leafHandle, deps) in this.chainDependencies)
        {
            if (deps.Contains(changedFileUri))
            {
                this.chainCache.TryRemove(leafHandle, out _);
                this.chainDependencies.TryRemove(leafHandle, out _);
                // Lookup cache must also be cleared so the next GetConfigurationChain
                // re-resolves the leaf file from its source directory.
                this.configFileLookupCache.Clear();
            }
        }
    }

    // PSBicep addition: we want to support looking up a configuration file even if the input path is a directory.
    private IDirectoryHandle GetSourceDirectory(IOUri sourceFileUri)
    {
        var filePath = sourceFileUri.GetFilePath();

        if (Directory.Exists(filePath))
        {
            // Produce a directory URI (with a trailing separator) the same way the Bicep CLI does.
            var directoryUri = IOUri.FromFilePath(Path.Combine(filePath, ".psbicep")).Resolve(".");
            return this.fileExplorer.GetDirectory(directoryUri);
        }

        return this.fileExplorer.GetFile(sourceFileUri).GetParent();
    }

    private static IBicepConfigurationChain GetBuiltInChain(IEnumerable<IDiagnostic>? diagnostics = null)
    {
        var builtInConfig = GetBuiltInConfiguration(diagnostics);

        return new BicepConfigurationChain(builtInConfig, [builtInConfig]);
    }

    private static IBicepConfiguration GetBuiltInConfiguration(IEnumerable<IDiagnostic>? diagnostics = null) =>
        diagnostics is null
            ? GetDefaultConfiguration()
            : GetDefaultConfiguration().With(diagnostics: diagnostics);

    private ResultWithDiagnostic<IBicepConfigurationChain> LoadChain(IFileHandle leafFileHandle)
    {
        var leafUri = leafFileHandle.Uri;
        var rawLayers = new List<(IFileHandle FileHandle, JsonElement Element)>();
        var visited = new HashSet<IOUri>();
        var currentFileHandle = leafFileHandle;

        while (true)
        {
            JsonElement currentElement;
            try
            {
                using var stream = currentFileHandle.OpenRead();
                currentElement = JsonElementFactory.CreateElementFromStream(stream);
            }
            catch (JsonException exception)
            {
                return new(ConfigDiagnosticBuilder.UnparsableBicepConfigFile(currentFileHandle.Uri, exception.Message));
            }
            catch (Exception exception)
            {
                return new(ConfigDiagnosticBuilder.UnloadableBicepConfigFile(currentFileHandle.Uri, exception.Message));
            }

            rawLayers.Add((currentFileHandle, currentElement));
            visited.Add(currentFileHandle.Uri);

            if (!currentElement.TryGetProperty("extends", out var extendsElement) ||
                extendsElement.ValueKind == JsonValueKind.Null)
            {
                break;
            }

            var extendsPath = extendsElement.GetString();

            if (string.IsNullOrWhiteSpace(extendsPath))
            {
                break;
            }

            if (IOUri.IsAbsoluteFilePath(extendsPath))
            {
                return new(ConfigDiagnosticBuilder.BicepConfigExtendsAbsolutePath(currentFileHandle.Uri));
            }

            var nextUri = currentFileHandle.Uri.Resolve(extendsPath);

            if (visited.Contains(nextUri))
            {
                var cycleDisplay = string.Join(" -> ", visited.Select(u => u.ToString())) + " -> " + nextUri;

                return new(ConfigDiagnosticBuilder.BicepConfigExtendsCycle(leafUri, cycleDisplay));
            }

            if (rawLayers.Count >= MaxChainDepth)
            {
                return new(ConfigDiagnosticBuilder.BicepConfigExtendsChainTooDeep(leafUri));
            }

            var nextFileHandle = this.fileExplorer.GetFile(nextUri);

            if (!nextFileHandle.Exists())
            {
                return new(ConfigDiagnosticBuilder.UnloadableBicepConfigFile(nextUri, "File not found."));
            }

            currentFileHandle = nextFileHandle;
        }

        // Record all config files this chain depends on for targeted cache invalidation.
        this.chainDependencies[leafFileHandle] = rawLayers
            .Select(layer => layer.FileHandle.Uri)
            .ToImmutableHashSet();

        return new(BuildChain(leafUri, rawLayers));
    }

    private static IBicepConfigurationChain BuildChain(IOUri leafUri, List<(IFileHandle FileHandle, JsonElement Element)> rawLayers)
    {
        // Merge: built-in first, then base configs in reverse order, leaf last (leaf wins).
        var accumulated = BuiltInConfigurationElement;

        foreach (var (_, element) in Enumerable.Reverse(rawLayers))
        {
            accumulated = accumulated.Merge(StripExtendsProperty(element));
        }

        IBicepConfiguration effectiveConfig;
        try
        {
            effectiveConfig = BicepConfiguration.Bind(accumulated, leafUri);
        }
        catch (ConfigurationException exception)
        {
            return GetBuiltInChain(diagnostics: [DiagnosticBuilder.ForDocumentStart().InvalidBicepConfigFile(leafUri, exception.Message)]);
        }

        // Annotate moduleAliasesMock aliases with the URI of the config file that declared each one.
        // Walk rawLayers, leaf-first: the first layer that contains an alias is the declaring layer.
        var declaringUriMap = BuildAliasDeclaringUriMap(rawLayers);
        if (declaringUriMap.Count > 0)
        {
            var annotatedMock = ((ModuleAliasesMockConfiguration)effectiveConfig.ModuleAliasesMock)
                .WithDeclaringUris(declaringUriMap);
            effectiveConfig = effectiveConfig.With(moduleAliasesMock: annotatedMock);
        }

        // Build per-layer configs so diagnostics can be attributed to the exact file that caused them.
        var layers = rawLayers
            .Select(layer =>
            {
                try
                {
                    var merged = BuiltInConfigurationElement.Merge(StripExtendsProperty(layer.Element));

                    return (IBicepConfiguration)BicepConfiguration.Bind(merged, layer.FileHandle.Uri);
                }
                catch (ConfigurationException)
                {
                    return GetDefaultConfiguration().With(configFileIdentifier: layer.FileHandle.Uri);
                }
            })
            .ToImmutableArray();

        return new BicepConfigurationChain(effectiveConfig, layers);
    }

    /// <summary>
    /// Builds a map from alias name to the URI of the config file that first declared it.
    /// Layers are visited leaf-first so the most-derived (leaf) declaration wins.
    /// </summary>
    private static ImmutableDictionary<string, IOUri> BuildAliasDeclaringUriMap(
        List<(IFileHandle FileHandle, JsonElement Element)> rawLayers)
    {
        var map = ImmutableDictionary.CreateBuilder<string, IOUri>(StringComparer.Ordinal);

        foreach (var (fileHandle, element) in rawLayers) // leaf first
        {
            if (!element.TryGetProperty(BicepConfiguration.ModuleAliasesMockKey, out var mockElement))
            {
                continue;
            }

            if (!mockElement.TryGetProperty("br", out var brElement))
            {
                continue;
            }

            foreach (var alias in brElement.EnumerateObject())
            {
                // First layer from leaf that declares this alias name is the declaring layer.
                map.TryAdd(alias.Name, fileHandle.Uri);
            }
        }

        return map.ToImmutable();
    }

    private static JsonElement StripExtendsProperty(JsonElement element)
    {
        if (!element.TryGetProperty("extends", out _))
        {
            return element;
        }

        var bufferWriter = new System.Buffers.ArrayBufferWriter<byte>();
        using var writer = new Utf8JsonWriter(bufferWriter);

        writer.WriteStartObject();
        foreach (var property in element.EnumerateObject())
        {
            if (!string.Equals(property.Name, "extends", StringComparison.Ordinal))
            {
                property.WriteTo(writer);
            }
        }
        writer.WriteEndObject();
        writer.Flush();

        return JsonElementFactory.CreateElement(bufferWriter.WrittenMemory);
    }

    private ResultWithDiagnostic<IFileHandle?> LookupConfigurationFile(IDirectoryHandle? directoryToLookup)
    {
        try
        {
            while (directoryToLookup is not null)
            {
                var configFileHandle = directoryToLookup.GetFile(LanguageConstants.BicepConfigurationFileName);

                if (configFileHandle.Exists())
                {
                    return new(configFileHandle);
                }

                directoryToLookup = directoryToLookup.GetParent();
            }
        }
        catch (IOException exception)
        {
            return new(ConfigDiagnosticBuilder.PotentialConfigDirectoryCouldNotBeScanned(directoryToLookup?.Uri, exception.Message));
        }

        return new((IFileHandle?)null);
    }
}
