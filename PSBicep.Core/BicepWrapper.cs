using System;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using System.Management.Automation;
using System.Threading.Tasks;
using Azure.Core;
using Bicep.Core.PrettyPrintV2;
using Bicep.Core.SourceGraph;
using Microsoft.Extensions.DependencyInjection;
using PSBicep.Core.Configuration;
using PSBicep.Core.Models;
using PSBicep.Core.Services;

namespace PSBicep.Core;

public class BicepWrapper(PSCmdlet cmdlet)
{
    private IServiceProvider _services => new ServiceCollection()
            .AddBicepCore()
            .AddBicepDecompiler()
            .AddPSBicep(cmdlet)
            .AddBicepServices()
            .BuildServiceProvider();
    private BicepBuilder _builder => _services.GetRequiredService<BicepBuilder>();
    private PSBicepDecompiler _decompiler => _services.GetRequiredService<PSBicepDecompiler>();
    private BicepFormatter _formatter => _services.GetRequiredService<BicepFormatter>();
    private BicepPublisher _publisher => _services.GetRequiredService<BicepPublisher>();
    private BicepRestorer _restorer => _services.GetRequiredService<BicepRestorer>();
    private BicepModuleFinder _moduleFinder => _services.GetRequiredService<BicepModuleFinder>();
    private BicepResourceConverter _resourceConverter => _services.GetRequiredService<BicepResourceConverter>();
    private BicepAuthentication _authentication => _services.GetRequiredService<BicepAuthentication>();
    private BicepConfiguration _configuration => _services.GetRequiredService<BicepConfiguration>();
    private BicepTypeResolver _typeResolver => _services.GetRequiredService<BicepTypeResolver>();

    public static string BicepVersion => FileVersionInfo.GetVersionInfo(typeof(Workspace).Assembly.Location).FileVersion ?? "dev";

    #region Authentication
    public void SetAuthentication(string? token = null, string? tenantId = null) =>
        _authentication.SetAuthentication(token, tenantId);

    public AccessToken? GetAccessToken() =>
        _authentication.GetAccessToken();
    #endregion

    #region Configuration
    public string GetCachePath(string path) =>
        _configuration.GetCachePath(path);

    public BicepConfigInfo GetBicepConfigInfo(BicepConfigScope scope, string path) =>
        _configuration.GetBicepConfigInfo(scope, path);
    #endregion

    #region Type Resolution
    public string ResolveBicepResourceType(string id) =>
        _typeResolver.ResolveBicepResourceType(id);

    public string[] GetApiVersions(string resourceTypeReference) =>
        _typeResolver.GetApiVersions(resourceTypeReference);
    #endregion

    #region Build
    public BuildResult Build(string bicepPath, string usingPath = "", bool noRestore = false) =>
        _builder.Build(bicepPath, usingPath, noRestore);

    public Task<BuildResult> BuildAsync(string bicepPath, string usingPath = "", bool noRestore = false) =>
        _builder.BuildAsync(bicepPath, usingPath, noRestore);
    #endregion

    #region Decompile
    public IDictionary<string, string> Decompile(string templatePath) =>
        _decompiler.Decompile(templatePath);

    public Task<IDictionary<string, string>> DecompileAsync(string templatePath) =>
        _decompiler.DecompileAsync(templatePath);
    #endregion

    #region Format
    public string Format(string content, string kind, string newline, string indentKind, int indentSize = 2, int width = 120, bool insertFinalNewline = false) =>
        _formatter.Format(content, kind, newline, indentKind, indentSize, width, insertFinalNewline);

    public string Format(string content, string configurationPath, string kind = "BicepFile") =>
        _formatter.Format(content, configurationPath, kind);

    public string Format(string content, PrettyPrinterV2Options options, BicepSourceFileKind fileKind = BicepSourceFileKind.BicepFile) =>
        _formatter.Format(content, options, fileKind);
    #endregion

    #region Publish
    public void Publish(string inputFilePath, string targetModuleReference, string token, string? documentationUri, bool publishSource = false, bool overwriteIfExists = false) =>
        _publisher.Publish(inputFilePath, targetModuleReference, token, documentationUri, publishSource, overwriteIfExists);

    public Task PublishAsync(string inputFilePath, string targetModuleReference, string token, string? documentationUri, bool publishSource = false, bool overwriteIfExists = false, bool skipRestore = false) =>
        _publisher.PublishAsync(inputFilePath, targetModuleReference, token, documentationUri, publishSource, overwriteIfExists, skipRestore);
    #endregion

    #region Restore
    public void Restore(string inputFilePath, bool forceModulesRestore = false) =>
        _restorer.Restore(inputFilePath, forceModulesRestore);

    public Task RestoreAsync(string inputFilePath, bool forceModulesRestore = false) =>
        _restorer.RestoreAsync(inputFilePath, forceModulesRestore);
    #endregion

    #region Module Finder
    public IList<BicepRepository> FindModules(string path, bool isRegistryEndpoint, string configurationPath) =>
        _moduleFinder.FindModules(path, isRegistryEndpoint, configurationPath);

    public IList<BicepRepository> FindModules() =>
        _moduleFinder.FindModules();
    #endregion

    #region Resource Converter
    public (string, string?) ConvertResourceToBicep(string resourceId, string resourceBody, string configurationPath, bool includeTargetScope = false, bool removeUnknownProperties = false) =>
        _resourceConverter.ConvertResourceToBicep(resourceId, resourceBody, configurationPath, includeTargetScope, removeUnknownProperties);

    public Task<(string, string?)> ConvertResourceToBicepAsync(string resourceId, string resourceBody, string configurationPath, bool includeTargetScope = false, bool removeUnknownProperties = false) =>
        _resourceConverter.ConvertResourceToBicepAsync(resourceId, resourceBody, configurationPath, includeTargetScope, removeUnknownProperties);

    public Hashtable ConvertResourceToBicep(Hashtable resourceDictionary, string configurationPath, bool includeTargetScope = false, bool removeUnknownProperties = false) =>
        _resourceConverter.ConvertResourceToBicep(resourceDictionary, configurationPath, includeTargetScope, removeUnknownProperties);

    public Task<Hashtable> ConvertResourceToBicepAsync(Hashtable resourceDictionary, string configurationPath, bool includeTargetScope = false, bool removeUnknownProperties = false) =>
        _resourceConverter.ConvertResourceToBicepAsync(resourceDictionary, configurationPath, includeTargetScope, removeUnknownProperties);
    #endregion
}
