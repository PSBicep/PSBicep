using System.IO.Abstractions;
using System.Management.Automation;
using Azure.Bicep.Types;
using Azure.Bicep.Types.Az;
using Bicep.Core;
using Bicep.Core.Analyzers.Interfaces;
using Bicep.Core.Analyzers.Linter;
using Bicep.Core.Configuration;
using Bicep.Core.Features;
using Bicep.Core.FileSystem;
using Bicep.Core.Registry;
using Bicep.Core.Registry.Auth;
using Bicep.Core.Registry.PublicRegistry;
using Bicep.Core.Semantics.Namespaces;
using Bicep.Core.TypeSystem.Providers;
using Bicep.Core.TypeSystem.Providers.Az;
using Bicep.Core.TypeSystem.Providers.K8s;
using Bicep.Core.TypeSystem.Providers.MicrosoftGraph;
using Bicep.Core.Utils;
using Bicep.Core.Workspaces;
using Bicep.Decompiler;
using Bicep.IO.Abstraction;
using Bicep.IO.FileSystem;
using Bicep.LanguageServer.Providers;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using Microsoft.Extensions.Logging;
using PSBicep.Core.Authentication;
using PSBicep.Core.Azure;
using PSBicep.Core.Configuration;
using PSBicep.Core.Logging;
using IOFileSystem = System.IO.Abstractions.FileSystem;

namespace PSBicep.Core;

public static class BicepExtensions
{
    public static ServiceCollection AddPSBicep(this ServiceCollection services, PSCmdlet cmdlet)
    {
        services
        .AddSingleton<DiagnosticLogger>()
        .AddSingleton<ILogger>(s => s.GetRequiredService<DiagnosticLogger>())
        .AddSingleton<IModuleDispatcher, ModuleDispatcher>()
        .AddSingleton<AzureResourceProvider>()
        .AddSingleton<IAzResourceProvider>(s => s.GetRequiredService<AzureResourceProvider>())
        .AddSingleton<AzTypeLoader>()
        .AddSingleton<ITypeLoader>(s => s.GetRequiredService<AzTypeLoader>())
        .AddSingleton<AzResourceTypeLoader>()
        .AddSingleton<K8sResourceTypeLoader>()
        .AddSingleton<MicrosoftGraphResourceTypeLoader>()
        .AddSingleton<Workspace>()
        .AddSingleton<BicepConfigurationManager>()
        .AddSingleton<BicepTokenCredentialFactory>()
        .Replace(ServiceDescriptor.Singleton<ITokenCredentialFactory>(s => s.GetRequiredService<BicepTokenCredentialFactory>()))
        .AddSingleton(cmdlet); ;

        // AddBicepCore()
        services
        .AddSingleton<INamespaceProvider, NamespaceProvider>()
        .AddSingleton<IResourceTypeProviderFactory, ResourceTypeProviderFactory>()
        .AddSingleton<IContainerRegistryClientFactory, ContainerRegistryClientFactory>()
        .AddSingleton<ITemplateSpecRepositoryFactory, TemplateSpecRepositoryFactory>()
        .AddSingleton<IModuleDispatcher, ModuleDispatcher>()
        .AddSingleton<IArtifactRegistryProvider, DefaultArtifactRegistryProvider>()
        .AddSingleton<ITokenCredentialFactory, TokenCredentialFactory>()
        .AddSingleton<IFileResolver, FileResolver>()
        .AddSingleton<IEnvironment, Environment>()
        .AddSingleton<IFileSystem, IOFileSystem>()
        .AddSingleton<IFileExplorer, FileSystemFileExplorer>()
        .AddSingleton<IConfigurationManager, ConfigurationManager>()
        .AddSingleton<IBicepAnalyzer, LinterAnalyzer>()
        .AddSingleton<IFeatureProviderFactory, FeatureProviderFactory>()
        .AddSingleton<ILinterRulesProvider, LinterRulesProvider>()
        .AddPublicRegistryModuleMetadataProviderServices()
        .AddSingleton<BicepCompiler>();

        // AddBicepDecompiler()
        services
        .AddSingleton<BicepDecompiler>();

        return services;
    }
}
