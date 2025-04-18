using System;
using Bicep.Core.Configuration;
using Bicep.Core.FileSystem;
using PSBicep.Core.Configuration;
using PSBicep.Core.Models;

namespace PSBicep.Core.Services;

public class BicepConfiguration
{
    private readonly BicepConfigurationManager configurationManager;

    public BicepConfiguration(BicepConfigurationManager configurationManager)
    {
        this.configurationManager = configurationManager;
    }

    public string GetCachePath(string path)
    {
        return configurationManager.GetConfiguration(PathHelper.FilePathToFileUrl(path)).CacheRootDirectory!;
    }

    public BicepConfigInfo GetBicepConfigInfo(BicepConfigScope scope, string path) =>
        configurationManager.GetConfigurationInfo(scope, PathHelper.FilePathToFileUrl(path ?? ""));
}