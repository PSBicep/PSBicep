using System;
using System.Diagnostics;
using System.Management.Automation;
using Bicep.Core.SourceGraph;
using Microsoft.Extensions.DependencyInjection;
using PSBicep.Core.Services;

namespace PSBicep.Core;

public class BicepService
{
    private readonly IServiceProvider _services;
    public readonly BicepBuilder builder;
    public readonly PSBicepDecompiler decompiler;
    public readonly BicepFormatter formatter;
    public readonly BicepPublisher publisher;
    public readonly BicepRestorer restorer;
    public readonly BicepModuleFinder moduleFinder;
    public readonly BicepResourceConverter resourceConverter;
    public readonly BicepAuthentication authentication;
    public readonly BicepConfiguration configuration;
    public readonly BicepTypeResolver typeResolver;

    public BicepService(PSCmdlet cmdlet)
    {
        _services = new ServiceCollection()
            .AddBicepCore()
            .AddBicepDecompiler()
            .AddPSBicep(cmdlet)
            .AddBicepServices()
            .BuildServiceProvider();

        builder = _services.GetRequiredService<BicepBuilder>();
        decompiler = _services.GetRequiredService<PSBicepDecompiler>();
        formatter = _services.GetRequiredService<BicepFormatter>();
        publisher = _services.GetRequiredService<BicepPublisher>();
        restorer = _services.GetRequiredService<BicepRestorer>();
        moduleFinder = _services.GetRequiredService<BicepModuleFinder>();
        resourceConverter = _services.GetRequiredService<BicepResourceConverter>();
        authentication = _services.GetRequiredService<BicepAuthentication>();
        configuration = _services.GetRequiredService<BicepConfiguration>();
        typeResolver = _services.GetRequiredService<BicepTypeResolver>();
    }

    public static string BicepVersion => FileVersionInfo.GetVersionInfo(typeof(Workspace).Assembly.Location).FileVersion ?? "dev";
}
