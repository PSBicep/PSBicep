﻿using System;
using System.IO;
using System.Reflection;
using System.Text.Json;
using Bicep.Core.Configuration;
using Bicep.Core.Json;
using Bicep.IO.Abstraction;
using PSBicep.Core.Models;

namespace PSBicep.Core.Configuration;

// Customizations and additions to out clone of Bicep.Core.Configuration.ConfigurationManager
// Our code is kept in separate file to simplify maintenance
public partial class BicepConfigurationManager
{
    private const string BuiltInConfigurationResourceName = "PSBicep.Core.Configuration.bicepconfig.json";

    public static BicepConfigInfo GetConfigurationInfo()
    {
        string configString = GetDefaultConfiguration().ToUtf8Json();
        return new BicepConfigInfo("Default", configString);
    }
    public BicepConfigInfo GetConfigurationInfo(BicepConfigScope mode, Uri sourceFileUri)
    {
        RootConfiguration config;
        switch (mode)
        {
            case BicepConfigScope.Default:
                config = GetDefaultConfiguration();
                return new BicepConfigInfo("Default", config.ToUtf8Json());
            case BicepConfigScope.Merged:
                config = GetConfiguration(sourceFileUri);
                return new BicepConfigInfo(config.ConfigFileUri?.Path ?? "Default", config.ToUtf8Json());
            case BicepConfigScope.Local:
                config = GetConfiguration(sourceFileUri);
                if (config.ConfigFileUri is not null)
                {
                    using var filestream = fileExplorer.GetFile((IOUri)config.ConfigFileUri).OpenRead();
                    var configString = JsonElementFactory.CreateElementFromStream(filestream).ToString();
                    return new BicepConfigInfo(config.ConfigFileUri, configString);
                }
                throw new FileNotFoundException("Local configuration file not found for path {path}!", sourceFileUri.LocalPath);
            default:
                throw new ArgumentException("BicepConfigMode not valid!");
        }
    }

    // From Bicep.Core, implement GetBuiltInConfiguration to replace IConfigurationManager.GetBuiltInConfiguration()
    private static RootConfiguration GetDefaultConfiguration() => BuiltInConfigurationLazy.Value;

    private static readonly Lazy<RootConfiguration> BuiltInConfigurationLazy = new(() => RootConfiguration.Bind(BuiltInConfigurationElement));

    protected static readonly JsonElement BuiltInConfigurationElement = GetBuiltInConfigurationElement();

    private static JsonElement GetBuiltInConfigurationElement()
    {
        using var stream = Assembly.GetExecutingAssembly().GetManifestResourceStream(BuiltInConfigurationResourceName) ??
            throw new InvalidOperationException("Could not get manifest resource stream for built-in configuration.");
        return JsonElementFactory.CreateElementFromStream(stream);
    }
}
