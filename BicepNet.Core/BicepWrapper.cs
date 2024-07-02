using Bicep.Cli.Logging;
using Bicep.Core;
using Bicep.Core.Analyzers.Interfaces;
using Bicep.Core.Configuration;
using Bicep.Core.Features;
using Bicep.Core.FileSystem;
using Bicep.Core.Modules;
using Bicep.Core.Registry;
using Bicep.Core.Semantics;
using Bicep.Core.Semantics.Namespaces;
using Bicep.Core.TypeSystem.Providers.Az;
using Bicep.Core.Utils;
using Bicep.Core.Workspaces;
using Bicep.Decompiler;
using BicepNet.Core.Authentication;
using BicepNet.Core.Azure;
using BicepNet.Core.Configuration;
using BicepNet.Core.Models;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Microsoft.VisualStudio.Threading;
using System;
using System.Diagnostics;
using System.IO;
using System.IO.Abstractions;

namespace BicepNet.Core;

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
    private readonly ModuleDispatcher moduleDispatcher;
    private readonly IArtifactRegistryProvider moduleRegistryProvider;
    private readonly IArtifactReferenceFactory artifactReferenceFactory;
    private readonly BicepNetTokenCredentialFactory tokenCredentialFactory;
    private readonly AzResourceTypeLoader azResourceTypeLoader;
    private readonly IEnvironment environment;
    private readonly IFileResolver fileResolver;
    private readonly IFileSystem fileSystem;
    private readonly BicepNetConfigurationManager configurationManager;
    private readonly IBicepAnalyzer bicepAnalyzer;
    private readonly IFeatureProviderFactory featureProviderFactory;
    private readonly BicepCompiler compiler;
    private readonly BicepDecompiler decompiler;
    private readonly Workspace workspace;
    private readonly RootConfiguration configuration;
    private readonly AzureResourceProvider azResourceProvider;

    public BicepWrapper(ILogger bicepLogger)
    {
        services = new ServiceCollection()
            .AddBicepNet(bicepLogger)
            .BuildServiceProvider();

        joinableTaskFactory = new JoinableTaskFactory(new JoinableTaskContext());
        logger = services.GetRequiredService<ILogger>();
        diagnosticLogger = services.GetRequiredService<DiagnosticLogger>();
        azResourceTypeLoader = services.GetRequiredService<AzResourceTypeLoader>();
        namespaceProvider = services.GetRequiredService<INamespaceProvider>();
        clientFactory = services.GetRequiredService<IContainerRegistryClientFactory>();
        moduleDispatcher = services.GetRequiredService<ModuleDispatcher>();
        moduleRegistryProvider = services.GetRequiredService<IArtifactRegistryProvider>();
        artifactReferenceFactory = services.GetRequiredService<IArtifactReferenceFactory>();
        tokenCredentialFactory = services.GetRequiredService<BicepNetTokenCredentialFactory>();
        tokenCredentialFactory.Logger = services.GetRequiredService<ILogger>();
        fileResolver = services.GetRequiredService<IFileResolver>();
        fileSystem = services.GetRequiredService<IFileSystem>();
        configurationManager = services.GetRequiredService<BicepNetConfigurationManager>();
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

    private DiagnosticSummary LogDiagnostics(Compilation compilation)
    {
        if (compilation is null)
        {
            throw new InvalidOperationException("Compilation is null. A compilation must exist before logging the diagnostics.");
        }

        return diagnosticLogger.LogDiagnostics(
            new DiagnosticOptions(Bicep.Cli.Arguments.DiagnosticsFormat.Default, false),
            compilation
        );
    }
}
