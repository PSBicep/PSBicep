using System;
using System.Diagnostics;
using System.Management.Automation;
using Bicep.Core.SourceGraph;
using Microsoft.Extensions.DependencyInjection;
using PSBicep.Core.Services;

namespace PSBicep.Core;

public class PSBicep
{
    private readonly IServiceProvider _services;
    public readonly BicepCoreService coreService;
    public readonly BicepRegistryService registryService;
    public readonly string bicepVersion;

    public PSBicep(PSCmdlet cmdlet)
    {
        _services = new ServiceCollection()
            .AddBicepCore()
            .AddPSBicep(cmdlet)
            .BuildServiceProvider();
        coreService = _services.GetRequiredService<BicepCoreService>();
        registryService = _services.GetRequiredService<BicepRegistryService>();
        bicepVersion = FileVersionInfo.GetVersionInfo(typeof(Workspace).Assembly.Location).FileVersion ?? "dev";
    }
}