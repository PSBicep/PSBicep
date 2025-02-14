using System;
using System.Diagnostics;
using System.IO;
using System.IO.Abstractions;
using System.Management.Automation;
using Bicep.Core;
using Bicep.Core.Analyzers.Interfaces;
using Bicep.Core.Configuration;
using Bicep.Core.Features;
using Bicep.Core.FileSystem;
using Bicep.Core.Modules;
using Bicep.Core.Registry;
using Bicep.Core.Resources;
using Bicep.Core.Semantics.Namespaces;
using Bicep.Core.TypeSystem.Providers.Az;
using Bicep.Core.Utils;
using Bicep.Core.Workspaces;
using Bicep.Decompiler;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Microsoft.VisualStudio.Threading;
using PSBicep.Core.Authentication;
using PSBicep.Core.Azure;
using PSBicep.Core.Configuration;
using PSBicep.Core.Logging;
using PSBicep.Core.Models;

namespace PSBicep.Core;

public partial class BicepWrapper
{
    public string BicepVersion { get; }
    public string OciCachePath { get; }
    public string TemplateSpecsCachePath { get; }

    private readonly ILogger logger;
    private readonly DiagnosticLogger diagnosticLogger;
    private readonly IServiceProvider services;

    // Services shared between commands
    private readonly JoinableTaskFactory joinableTaskFactory;
    private readonly INamespaceProvider namespaceProvider;
    private readonly IContainerRegistryClientFactory clientFactory;
    private readonly IModuleDispatcher moduleDispatcher;
    private readonly IArtifactRegistryProvider moduleRegistryProvider;
    private readonly BicepTokenCredentialFactory tokenCredentialFactory;
    private readonly AzResourceTypeLoader azResourceTypeLoader;
    private readonly IEnvironment environment;
    private readonly IFileResolver fileResolver;
    private readonly IFileSystem fileSystem;
    private readonly BicepConfigurationManager configurationManager;
    private readonly IBicepAnalyzer bicepAnalyzer;
    private readonly IFeatureProviderFactory featureProviderFactory;
    private readonly BicepCompiler compiler;
    private readonly BicepDecompiler decompiler;
    private readonly Workspace workspace;
    private readonly RootConfiguration configuration;
    private readonly AzureResourceProvider azResourceProvider;

    public BicepWrapper(PSCmdlet cmdlet)
    {
        services = new ServiceCollection()
            .AddPSBicep(cmdlet)
            .BuildServiceProvider();

        joinableTaskFactory = new JoinableTaskFactory(new JoinableTaskContext());
        logger = services.GetRequiredService<ILogger>();
        diagnosticLogger = services.GetRequiredService<DiagnosticLogger>();
        azResourceTypeLoader = services.GetRequiredService<AzResourceTypeLoader>();
        namespaceProvider = services.GetRequiredService<INamespaceProvider>();
        clientFactory = services.GetRequiredService<IContainerRegistryClientFactory>();
        moduleDispatcher = services.GetRequiredService<IModuleDispatcher>();
        moduleRegistryProvider = services.GetRequiredService<IArtifactRegistryProvider>();
        tokenCredentialFactory = services.GetRequiredService<BicepTokenCredentialFactory>();
        tokenCredentialFactory.Logger = services.GetRequiredService<ILogger>();
        fileResolver = services.GetRequiredService<IFileResolver>();
        fileSystem = services.GetRequiredService<IFileSystem>();
        configurationManager = services.GetRequiredService<BicepConfigurationManager>();
        bicepAnalyzer = services.GetRequiredService<IBicepAnalyzer>();
        featureProviderFactory = services.GetRequiredService<IFeatureProviderFactory>();
        compiler = services.GetRequiredService<BicepCompiler>();
        environment = services.GetRequiredService<IEnvironment>();

        decompiler = services.GetRequiredService<BicepDecompiler>();

        workspace = services.GetRequiredService<Workspace>();
        configuration = configurationManager.GetConfiguration(new Uri("inmemory://main.bicep"));
        azResourceProvider = services.GetRequiredService<AzureResourceProvider>();

        BicepVersion = FileVersionInfo.GetVersionInfo(typeof(Workspace).Assembly.Location).FileVersion ?? "dev";
        OciCachePath = Path.Combine(services.GetRequiredService<IFeatureProviderFactory>().GetFeatureProvider(new Uri("inmemory:///main.bicp")).CacheRootDirectory, ArtifactReferenceSchemes.Oci);
        TemplateSpecsCachePath = Path.Combine(services.GetRequiredService<IFeatureProviderFactory>().GetFeatureProvider(new Uri("inmemory:///main.bicp")).CacheRootDirectory, ArtifactReferenceSchemes.TemplateSpecs);
    }

    public string GetOciCachePath(string path) =>
        Path.Combine(services.GetRequiredService<IFeatureProviderFactory>().GetFeatureProvider(new Uri(path)).CacheRootDirectory, ArtifactReferenceSchemes.Oci);

    public string GetTemplateSpecsCachePath(string path) =>
        Path.Combine(services.GetRequiredService<IFeatureProviderFactory>().GetFeatureProvider(new Uri(path)).CacheRootDirectory, ArtifactReferenceSchemes.TemplateSpecs);

    public void ClearAuthentication() => tokenCredentialFactory.Clear();
    public void SetAuthentication(string? token = null, string? tenantId = null) =>
        tokenCredentialFactory.SetToken(configuration.Cloud.ActiveDirectoryAuthorityUri, token, tenantId);

    public BicepAccessToken? GetAccessToken()
    {
        // Gets the token using the same request context as when connecting
        var token = tokenCredentialFactory.Credential?.GetToken(tokenCredentialFactory.TokenRequestContext, System.Threading.CancellationToken.None);

        if (!token.HasValue)
        {
            logger.LogWarning("No access token currently stored!");
            return null;
        }

        var tokenValue = token.Value;
        return new BicepAccessToken(tokenValue.Token, tokenValue.ExpiresOn);
    }

    public BicepConfigInfo GetBicepConfigInfo(BicepConfigScope scope, string path) =>
        configurationManager.GetConfigurationInfo(scope, PathHelper.FilePathToFileUrl(path ?? ""));

    public string ResolveBicepResourceType(string id)
    {
        var resourceId = AzureHelpers.ValidateResourceId(id);
        return BicepHelper.ResolveBicepTypeDefinition(resourceId.FullyQualifiedType, azResourceTypeLoader, logger).ToString();
    }

    public string[] GetApiVersions(string resourceTypeReference)
    {
        return BicepHelper.GetApiVersions(ResourceTypeReference.Parse(resourceTypeReference), azResourceTypeLoader);
    }
}
