using System.IO.Abstractions;
using Azure.Bicep.Types;
using Azure.Bicep.Types.Az;
using Bicep.Core;
using Bicep.Core.Analyzers.Interfaces;
using Bicep.Core.Analyzers.Linter;
using Bicep.Core.Analyzers.Linter.ApiVersions;
using Bicep.Core.Configuration;
using Bicep.Core.Documentation;
using Bicep.Core.Features;
using Bicep.Core.AzureApi;
using Bicep.Core.Registry;
using Bicep.Core.Registry.Oci;
using Bicep.Core.Registry.Oci.Oras;
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
        .AddSingleton<ActiveSourceFileSet>()
        .AddSingleton<PSBicepConfigurationManager>()
        .AddSingleton<BicepTokenCredentialFactory>()
        .AddSingleton<JoinableTaskContext>()
        .AddSingleton<JoinableTaskFactory>()
        .AddSingleton<BicepCoreService>()
        .AddSingleton<BicepRegistryService>();

    public static IServiceCollection AddBicepCore(this IServiceCollection services) => services
        .AddSingleton<INamespaceProvider, NamespaceProvider>()
        .AddSingleton(_ => AzResourceTypeProvider.Instance)
        .AddSingleton<AzApiVersionProvider>()
        .AddSingleton<IResourceTypeProviderFactory, ResourceTypeProviderFactory>()
        .AddSingleton<IContainerRegistryClientFactory, ContainerRegistryClientFactory>()
        .AddSingleton<AzureContainerRegistryManager>()
        .AddSingleton<DockerCredentialProvider>()
        .AddSingleton<OrasOciRegistryTransport>()
        .AddSingleton<IOciRegistryTransportFactory, OciRegistryTransportFactory>()
        .AddSingleton<ITemplateSpecRepositoryFactory, TemplateSpecRepositoryFactory>()
        .AddSingleton<IModuleDispatcher, ModuleDispatcher>()
        .AddSingleton<RegistryConfiguration>(serviceProvider =>
        {
            var environment = serviceProvider.GetRequiredService<IEnvironment>();
            var additionalTrustedRegistries = RegistryConfiguration.ParseTrustedRegistries(environment.GetVariable("BICEP_TRUSTED_REGISTRIES"));
            return new RegistryConfiguration(PermitUntrustedRegistries: false, additionalTrustedRegistries);
        })
        .AddSingleton<IArtifactRegistryProvider, DefaultArtifactRegistryProvider>()
        .AddSingleton<ITokenCredentialFactory, TokenCredentialFactory>()
        .AddSingleton<IArmClientProvider, ArmClientProvider>()
        .AddSingleton<IEnvironment, Environment>()
        .AddSingleton<IFileSystem, LocalFileSystem>()
        .AddSingleton<IFileExplorer, FileSystemFileExplorer>()
        .AddSingleton<IAuxiliaryFileCache, AuxiliaryFileCache>()
        .AddSingleton<IBicepConfigurationManager>(sp => sp.GetRequiredService<PSBicepConfigurationManager>())
        .AddSingleton<IBicepAnalyzer, LinterAnalyzer>()
        .AddSingleton<IFeatureProviderFactory, FeatureProviderFactory>()
        .AddSingleton<ILinterRulesProvider, LinterRulesProvider>()
        .AddSingleton<ISourceFileFactory, SourceFileFactory>()
        .AddBicepRegistryCatalogServices()
        .AddSingleton<IBicepDocumentationGenerator, BicepDocumentationGenerator>()
        .AddSingleton<BicepCompiler>()
        .AddSingleton<BicepDecompiler>();
}
