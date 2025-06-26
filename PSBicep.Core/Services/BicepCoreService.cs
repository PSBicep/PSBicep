using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Management.Automation;
using System.Text.Json;
using System.Threading.Tasks;
using Bicep.Core;
using Bicep.Core.FileSystem;
using Bicep.Core.PrettyPrintV2;
using Bicep.Core.Registry;
using Bicep.Core.Resources;
using Bicep.Core.SourceGraph;
using Bicep.Core.TypeSystem.Providers.Az;
using Bicep.Decompiler;
using Bicep.IO.Abstraction;
using Microsoft.Extensions.Logging;
using Microsoft.VisualStudio.Threading;
using PSBicep.Core.Authentication;
using PSBicep.Core.Azure;
using PSBicep.Core.Configuration;
using PSBicep.Core.Logging;
using PSBicep.Core.Models;

namespace PSBicep.Core.Services;

public class BicepCoreService
{
    private readonly JoinableTaskFactory joinableTaskFactory;
    private readonly BicepCompiler compiler;
    private readonly DiagnosticLogger diagnosticLogger;
    private readonly BicepConfigurationManager configurationManager;
    private readonly IFileResolver fileResolver;
    private readonly BicepDecompiler decompiler;
    private readonly AzResourceTypeLoader azResourceTypeLoader;
    private readonly IModuleDispatcher moduleDispatcher;
    private readonly IFileExplorer fileExplorer;
    private readonly BicepTokenCredentialFactory tokenCredentialFactory;

    public BicepCoreService(
        JoinableTaskFactory joinableTaskFactory,
        BicepCompiler compiler,
        DiagnosticLogger diagnosticLogger,
        BicepConfigurationManager configurationManager,
        IFileResolver fileResolver,
        BicepDecompiler decompiler,
        AzResourceTypeLoader azResourceTypeLoader,
        IModuleDispatcher moduleDispatcher,
        IFileExplorer fileExplorer,
        BicepTokenCredentialFactory tokenCredentialFactory)
    {
        this.joinableTaskFactory = joinableTaskFactory;
        this.compiler = compiler;
        this.diagnosticLogger = diagnosticLogger;
        this.configurationManager = configurationManager;
        this.fileResolver = fileResolver;
        this.decompiler = decompiler;
        this.azResourceTypeLoader = azResourceTypeLoader;
        this.moduleDispatcher = moduleDispatcher;
        this.fileExplorer = fileExplorer;
        this.tokenCredentialFactory = tokenCredentialFactory;
    }

    public void InitializeLogger(PSCmdlet cmdlet)
    {
        diagnosticLogger.Initialize(cmdlet);
    }

    public void UnloadLogger()
    {
        diagnosticLogger.Unload();
    }

    /// <summary>
    /// Restores external Bicep modules to the local cache
    /// </summary>
    /// <param name="inputFilePath">Path to the Bicep file containing module references</param>
    /// <param name="forceModulesRestore">If true, forces restoration even if modules are already cached</param>
    public void Restore(string inputFilePath, bool forceModulesRestore = false) =>
        joinableTaskFactory.Run(() => RestoreAsync(inputFilePath, forceModulesRestore));

    /// <summary>
    /// Restores external Bicep modules to the local cache Asynchronously
    /// </summary>
    /// <param name="inputFilePath">Path to the Bicep file containing module references</param>
    /// <param name="forceModulesRestore">If true, forces restoration even if modules are already cached</param>
    /// <returns>A task representing the asynchronous operation</returns>
    public async Task RestoreAsync(string inputFilePath, bool forceModulesRestore = false)
    {
        diagnosticLogger.Log(LogLevel.Trace, "Restoring external modules to local cache for file {inputFilePath}", inputFilePath);
        var inputPath = PathHelper.ResolvePath(inputFilePath);
        var inputUri = PathHelper.FilePathToFileUrl(inputPath);

        var compilation = compiler.CreateCompilationWithoutRestore(inputUri, markAllForRestore: forceModulesRestore);
        var restoreDiagnostics = await compiler.Restore(compilation, forceRestore: forceModulesRestore);
        diagnosticLogger.LogDiagnostics(DiagnosticOptions.Default, restoreDiagnostics);
    }

    /// <summary>
    /// Builds a Bicep file into an ARM template
    /// </summary>
    /// <param name="bicepPath">Path to the Bicep file to build</param>
    /// <param name="noRestore">If true, skips restoring modules during compilation</param>
    /// <returns>A BuildResult containing the compiled ARM template and metadata</returns>
    public BuildResult Build(string bicepPath, bool noRestore = false) =>
        joinableTaskFactory.Run(() => BuildAsync(bicepPath, noRestore));

    /// <summary>
    /// Builds a Bicep file into an ARM template Asynchronously
    /// </summary>
    /// <param name="bicepPath">Path to the Bicep file to build</param>
    /// <param name="noRestore">If true, skips restoring modules during compilation</param>
    /// <returns>A task returning a BuildResult containing the compiled ARM template and metadata</returns>
    public async Task<BuildResult> BuildAsync(string bicepPath, bool noRestore = false)
    {
        var inputPath = PathHelper.ResolvePath(bicepPath);
        var inputUri = PathHelper.FilePathToFileUrl(inputPath);

        if (!IsBicepFile(inputUri) && !IsBicepparamsFile(inputUri))
        {
            throw new InvalidOperationException($"Input file '{inputPath}' must have a .bicep or .bicepparam extension.");
        }

        var compilation = await compiler.CreateCompilation(inputUri, skipRestore: noRestore);

        var summary = diagnosticLogger.LogDiagnostics(compilation);

        if (summary.HasErrors)
        {
            throw new InvalidOperationException($"Failed to compile file: {inputPath}");
        }

        var fileKind = compilation.SourceFileGrouping.EntryPoint.FileKind;

        switch (fileKind)
        {
            case BicepSourceFileKind.BicepFile:
                var template = compilation.Emitter.Template();
                return new BuildResult(
                    Parameters: null,
                    TemplateSpecId: null,
                    Template: template.Template,
                    SourceMap: template.SourceMap);
            case BicepSourceFileKind.ParamsFile:
                var parameters = compilation.Emitter.Parameters();
                return new BuildResult(
                    Parameters: parameters.Parameters,
                    TemplateSpecId: parameters.TemplateSpecId,
                    Template: parameters.Template?.Template,
                    SourceMap: parameters.Template?.SourceMap);
            default:
                throw new NotImplementedException($"Unexpected file kind '{fileKind}'");
        }
    }

    /// <summary>
    /// Gets the path to the Bicep module cache directory
    /// </summary>
    /// <param name="path">Path to use for configuration context</param>
    /// <returns>The full path to the Bicep module cache directory</returns>
    public string GetCachePath(string path)
    {
        return configurationManager.GetConfiguration(PathHelper.FilePathToFileUrl(path)).CacheRootDirectory!;
    }

    /// <summary>
    /// Gets Bicep configuration information for the specified scope and path
    /// </summary>
    /// <param name="scope">The configuration scope (Merged, Default or Local)</param>
    /// <param name="path">Path to the file or directory used to find bicepconfig.json</param>
    /// <returns>BicepConfigInfo object containing configuration details</returns>
    public BicepConfigInfo GetBicepConfigInfo(BicepConfigScope scope, string path) =>
        configurationManager.GetConfigurationInfo(scope, PathHelper.FilePathToFileUrl(path ?? ""));

    /// <summary>
    /// Decompiles an ARM template into Bicep code
    /// </summary>
    /// <param name="templatePath">Path to the ARM template JSON file</param>
    /// <returns>Dictionary mapping output file paths to decompiled Bicep code</returns>
    public IDictionary<string, string> Decompile(string templatePath) =>
        joinableTaskFactory.Run(() => DecompileAsync(templatePath));

    /// <summary>
    /// Decompiles an ARM template into Bicep code
    /// </summary>
    /// <param name="templatePath">Path to the ARM template JSON file</param>
    /// <returns>A task returning a dictionary mapping output file paths to decompiled Bicep code</returns>
    public async Task<IDictionary<string, string>> DecompileAsync(string templatePath)
    {
        var inputPath = PathHelper.ResolvePath(templatePath);
        var inputUri = PathHelper.FilePathToFileUrl(inputPath);

        if (!fileResolver.TryRead(inputUri).IsSuccess(out var jsonContent))
        {
            throw new InvalidOperationException($"Failed to read {inputUri}");
        }

        var template = new Dictionary<string, string>();
        var decompilation = await decompiler.Decompile(PathHelper.ChangeToBicepExtension(inputUri), jsonContent);

        foreach (var (fileUri, bicepOutput) in decompilation.FilesToSave)
        {
            template.Add(fileUri.LocalPath, bicepOutput);
        }

        return template;
    }

    /// <summary>
    /// Resolves an Azure resource ID to its corresponding Bicep resource type,
    /// allowing you to skip a number of recent API versions and optionally ignore preview versions.
    /// </summary>
    /// <param name="id">The Azure resource ID to resolve.</param>
    /// <param name="skip">The number of most recent API versions to skip when selecting the version.</param>
    /// <param name="avoidPreview">If true, excludes preview API versions from consideration.</param>
    /// <returns>
    /// A BicepResourceTypeReference containing the resolved resource type and selected API version.
    /// </returns>
    public BicepResourceTypeReference ResolveBicepResourceType(string id, int skip = 0, bool avoidPreview = false)
    {
        var resourceId = AzureHelpers.ValidateResourceId(id);
        var resourceTypeReference = BicepHelper.ResolveBicepTypeDefinition(
            resourceId.FullyQualifiedType,
            azResourceTypeLoader,
            logger: diagnosticLogger,
            skip,
            avoidPreview);

        return new BicepResourceTypeReference(resourceTypeReference.Type, resourceTypeReference.ApiVersion);
    }

    /// <summary>
    /// Gets all available API versions for a specific Azure resource type
    /// </summary>
    /// <param name="resourceTypeReference">The resource type reference string (e.g., 'Microsoft.Network/virtualNetworks')</param>
    /// <returns>Array of available API versions for the resource type</returns>
    /// TODO: Add parameter to ignore preview API versions
    public string[] GetApiVersions(string resourceTypeReference, int skip = 0, bool avoidPreview = false)
    {
        return BicepHelper.GetApiVersions(ResourceTypeReference.Parse(resourceTypeReference), azResourceTypeLoader, diagnosticLogger, skip, avoidPreview);
    }

    /// <summary>
    /// Converts a single Azure resource to Bicep
    /// </summary>
    /// <param name="resourceId">The ID of the Azure resource, used to find type and API Version</param>
    /// <param name="resourceBody">The JSON representation of the resource</param>
    /// <param name="configurationPath">Path used to find bicepconfig.json</param>
    /// <param name="includeTargetScope">If true, includes a targetScope declaration in the generated Bicep</param>
    /// <param name="removeUnknownProperties">If true, removes properties not found in the resource type definition</param>
    /// <returns>A tuple containing the resource ID and generated Bicep code</returns>
    public (string, string?) ConvertResourceToBicep(string resourceId, string resourceBody, string configurationPath, bool includeTargetScope = false, bool removeUnknownProperties = false) =>
        joinableTaskFactory.Run(() => ConvertResourceToBicepAsync(resourceId, resourceBody, configurationPath, includeTargetScope, removeUnknownProperties));

    /// <summary>
    /// Converts a single Azure resource to Bicep Asynchronously
    /// </summary>
    /// <param name="resourceId">The ID of the Azure resource, used to find type and API Version</param>
    /// <param name="resourceBody">The JSON representation of the resource</param>
    /// <param name="configurationPath">Path used to find bicepconfig.json</param>
    /// <param name="includeTargetScope">If true, includes a targetScope declaration in the generated Bicep</param>
    /// <param name="removeUnknownProperties">If true, removes properties not found in the resource type definition</param>
    /// <returns>A task returning a tuple containing the resource ID and generated Bicep code</returns>
    public async Task<(string, string?)> ConvertResourceToBicepAsync(string resourceId, string resourceBody, string configurationPath, bool includeTargetScope = false, bool removeUnknownProperties = false)
    {
        var id = AzureHelpers.ValidateResourceId(resourceId);
        var matchedType = BicepHelper.ResolveBicepTypeDefinition(id.FullyQualifiedType, azResourceTypeLoader, logger: diagnosticLogger);
        JsonElement resource = JsonSerializer.Deserialize<JsonElement>(resourceBody);
        var configuration = configurationManager.GetConfiguration(PathHelper.FilePathToFileUrl(configurationPath));
        var template = await Task.Run(() => AzureHelpers.GenerateBicepTemplate(compiler, id, matchedType, resource, configuration, includeTargetScope, removeUnknownProperties));
        return (resourceId, template);
    }

    /// <summary>
    /// Converts multiple Azure resources to Bicep
    /// </summary>
    /// <param name="resourceDictionary">Hashtable mapping resource IDs to resource JSON</param>
    /// <param name="configurationPath">Path used to find bicepconfig.json</param>
    /// <param name="includeTargetScope">If true, includes a targetScope declaration in the generated Bicep</param>
    /// <param name="removeUnknownProperties">If true, removes properties not found in the resource type definition</param>
    /// <returns>Hashtable mapping resource IDs to generated Bicep code</returns>
    public Hashtable ConvertResourceToBicep(Hashtable resourceDictionary, string configurationPath, bool includeTargetScope = false, bool removeUnknownProperties = false) =>
        joinableTaskFactory.Run(() => ConvertResourceToBicepAsync(resourceDictionary, configurationPath, includeTargetScope, removeUnknownProperties));

    /// <summary>
    /// Converts multiple Azure resources to Bicep Asynchronously
    /// </summary>
    /// <param name="resourceDictionary">Hashtable mapping resource IDs to resource JSON</param>
    /// <param name="configurationPath">Path used to find bicepconfig.json</param>
    /// <param name="includeTargetScope">If true, includes a targetScope declaration in the generated Bicep</param>
    /// <param name="removeUnknownProperties">If true, removes properties not found in the resource type definition</param>
    /// <returns>A task returning a Hashtable mapping resource IDs to generated Bicep code</returns>
    public async Task<Hashtable> ConvertResourceToBicepAsync(Hashtable resourceDictionary, string configurationPath, bool includeTargetScope = false, bool removeUnknownProperties = false)
    {
        var taskList = new List<Task<(string, string?)>>();
        foreach (DictionaryEntry entry in resourceDictionary)
        {
            taskList.Add(ConvertResourceToBicepAsync(entry.Key.ToString()!, entry.Value!.ToString()!, configurationPath, includeTargetScope, removeUnknownProperties));
        }
        var templates = await Task.WhenAll(taskList);
        Hashtable output = [];
        foreach (var template in templates)
        {
            output.Add(template.Item1, template.Item2);
        }
        return output;
    }

    /// <summary>
    /// Formats Bicep code according to the specified formatting options
    /// </summary>
    /// <param name="content">The Bicep code to format</param>
    /// <param name="kind">The kind of file ('BicepFile' or 'ParamsFile')</param>
    /// <param name="newline">The newline style to use (e.g., 'LF', 'CRLF')</param>
    /// <param name="indentKind">The indentation style ('Space' or 'Tab')</param>
    /// <param name="indentSize">The number of spaces or tabs to use for indentation</param>
    /// <param name="width">The maximum line width before wrapping</param>
    /// <param name="insertFinalNewline">If true, ensures the file ends with a newline</param>
    /// <returns>The formatted Bicep code</returns>
    public string Format(string content, string kind, string newline, string indentKind, int indentSize = 2, int width = 120, bool insertFinalNewline = false)
    {
        var fileKind = (BicepSourceFileKind)Enum.Parse(typeof(BicepSourceFileKind), kind, true);
        var newlineOption = (NewlineKind)Enum.Parse(typeof(NewlineKind), newline, true);
        var indentKindOption = (IndentKind)Enum.Parse(typeof(IndentKind), indentKind, true);

        var options = new PrettyPrinterV2Options(indentKindOption, newlineOption, indentSize, width, insertFinalNewline);

        return Format(content, options, fileKind);
    }

    /// <summary>
    /// Formats Bicep code according to configuration from a specified file path
    /// </summary>
    /// <param name="content">The Bicep code to format</param>
    /// <param name="configurationPath">Path to the Bicep configuration file</param>
    /// <param name="kind">The kind of file ('BicepFile' or 'ParamsFile')</param>
    /// <returns>The formatted Bicep code</returns>
    public string Format(string content, string configurationPath, string kind = "BicepFile")
    {
        var configuration = configurationManager.GetConfiguration(PathHelper.FilePathToFileUrl(configurationPath ?? ""));
        var fileKind = (BicepSourceFileKind)Enum.Parse(typeof(BicepSourceFileKind), kind, true);
        return Format(content, configuration.Formatting.Data, fileKind);
    }

    /// <summary>
    /// Formats Bicep code using the specified pretty printer options
    /// </summary>
    /// <param name="content">The Bicep code to format</param>
    /// <param name="options">Formatting options to use</param>
    /// <param name="fileKind">The kind of file (Bicep or parameters)</param>
    /// <returns>The formatted Bicep code</returns>
    public string Format(string content, PrettyPrinterV2Options options, BicepSourceFileKind fileKind = BicepSourceFileKind.BicepFile)
    {
        var uri = fileKind == BicepSourceFileKind.BicepFile ? new Uri("inmemory:///generated.bicep") : new Uri("inmemory:///generated.bicepparams");
        if (compiler.SourceFileFactory.CreateSourceFile(uri, content) is not BicepSourceFile sourceFile)
        {
            throw new InvalidOperationException("Unable to create Bicep source file.");
        }

        var context = PrettyPrinterV2Context.Create(options, sourceFile.LexingErrorLookup, sourceFile.ParsingErrorLookup);

        using var stringWriter = new StringWriter();
        PrettyPrinterV2.PrintTo(stringWriter, sourceFile.ProgramSyntax, context);
        return stringWriter.ToString();
    }

    private static bool IsBicepFile(Uri inputUri) => PathHelper.HasBicepExtension(inputUri);
    private static bool IsBicepparamsFile(Uri inputUri) => PathHelper.HasBicepparamsExtension(inputUri);

}