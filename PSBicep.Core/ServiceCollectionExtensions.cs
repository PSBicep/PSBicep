using System.IO.Abstractions;
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
using Bicep.Core.Registry.Catalog.Implementation;
using Bicep.Core.Semantics.Namespaces;
using Bicep.Core.SourceGraph;
using Bicep.Core.TypeSystem.Providers;
using Bicep.Core.TypeSystem.Providers.Az;
using Bicep.Core.Utils;
using Bicep.Decompiler;
using Bicep.IO.Abstraction;
using Bicep.IO.FileSystem;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.VisualStudio.Threading;
using PSBicep.Core.Authentication;
using PSBicep.Core.Configuration;
using PSBicep.Core.Logging;
using PSBicep.Core.Services;
using Environment = Bicep.Core.Utils.Environment;
using LocalFileSystem = System.IO.Abstractions.FileSystem;

namespace PSBicep.Core;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddPSBicep(this IServiceCollection services) => services
        .AddSingleton<DiagnosticLogger>()
        .AddSingleton<ITypeLoader, AzTypeLoader>()
        .AddSingleton<AzResourceTypeLoader>()
        .AddSingleton<Workspace>()
        .AddSingleton<BicepConfigurationManager>()
        .AddSingleton<BicepTokenCredentialFactory>()
        .AddSingleton<JoinableTaskContext>()
        .AddSingleton<JoinableTaskFactory>()
        .AddSingleton<BicepCoreService>()
        .AddSingleton<BicepRegistryService>();

    public static IServiceCollection AddBicepCore(this IServiceCollection services) => services
        .AddSingleton<INamespaceProvider, NamespaceProvider>()
        .AddSingleton<IResourceTypeProviderFactory, ResourceTypeProviderFactory>()
        .AddSingleton<IContainerRegistryClientFactory, ContainerRegistryClientFactory>()
        .AddSingleton<ITemplateSpecRepositoryFactory, TemplateSpecRepositoryFactory>()
        .AddSingleton<IModuleDispatcher, ModuleDispatcher>()
        .AddSingleton<IArtifactRegistryProvider, DefaultArtifactRegistryProvider>()
        .AddSingleton<ITokenCredentialFactory, TokenCredentialFactory>()
        .AddSingleton<IFileResolver, FileResolver>()
        .AddSingleton<IEnvironment, Environment>()
        .AddSingleton<IFileSystem, LocalFileSystem>()
        .AddSingleton<IFileExplorer, FileSystemFileExplorer>()
        .AddSingleton<IAuxiliaryFileCache, AuxiliaryFileCache>()
        .AddSingleton<IConfigurationManager, ConfigurationManager>()
        .AddSingleton<IBicepAnalyzer, LinterAnalyzer>()
        .AddSingleton<IFeatureProviderFactory, FeatureProviderFactory>()
        .AddSingleton<ILinterRulesProvider, LinterRulesProvider>()
        .AddSingleton<ISourceFileFactory, SourceFileFactory>()
        .AddRegistryCatalogServices()
        .AddSingleton<BicepCompiler>()
        .AddSingleton<BicepDecompiler>();
}