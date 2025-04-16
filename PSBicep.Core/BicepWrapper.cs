using System;
using System.Diagnostics;
using System.Management.Automation;
using Azure.Core;
using Bicep.Core;
using Bicep.Core.FileSystem;
using Bicep.Core.Registry;
using Bicep.Core.Resources;
using Bicep.Core.SourceGraph;
using Bicep.Core.TypeSystem.Providers.Az;
using Bicep.Decompiler;
using Bicep.IO.Abstraction;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Microsoft.VisualStudio.Threading;
using PSBicep.Core.Authentication;
using PSBicep.Core.Azure;
using PSBicep.Core.Configuration;
using PSBicep.Core.Logging;
using PSBicep.Core.Models;

namespace PSBicep.Core;

public partial class BicepWrapper(PSCmdlet cmdlet)
{
    private readonly IServiceProvider services = new ServiceCollection()
            .AddBicepCore()
            .AddBicepDecompiler()
            .AddPSBicep(cmdlet)
            .BuildServiceProvider();

    private JoinableTaskFactory joinableTaskFactory => services.GetRequiredService<JoinableTaskFactory>();
    private ILogger logger => services.GetRequiredService<ILogger>();
    private DiagnosticLogger diagnosticLogger => services.GetRequiredService<DiagnosticLogger>();
    private AzResourceTypeLoader azResourceTypeLoader => services.GetRequiredService<AzResourceTypeLoader>();
    private IModuleDispatcher moduleDispatcher => services.GetRequiredService<IModuleDispatcher>();
    private BicepTokenCredentialFactory tokenCredentialFactory => services.GetRequiredService<BicepTokenCredentialFactory>();
    private IFileResolver fileResolver => services.GetRequiredService<IFileResolver>();
    private IFileExplorer fileExplorer => services.GetRequiredService<IFileExplorer>();
    private BicepConfigurationManager configurationManager => services.GetRequiredService<BicepConfigurationManager>();
    private BicepCompiler compiler => services.GetRequiredService<BicepCompiler>();
    private BicepDecompiler decompiler => services.GetRequiredService<BicepDecompiler>();

    public static string BicepVersion => FileVersionInfo.GetVersionInfo(typeof(Workspace).Assembly.Location).FileVersion ?? "dev";
    public void SetAuthentication(string? token = null, string? tenantId = null) =>
        tokenCredentialFactory.SetToken(new Uri("inmemory:///main.bicp"), token, tenantId);

    public AccessToken? GetAccessToken()
    {
        return tokenCredentialFactory.GetToken();
    }

    public string GetCachePath(string path)
    {
        return configurationManager.GetConfiguration(PathHelper.FilePathToFileUrl(path)).CacheRootDirectory!;
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
