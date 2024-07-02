using BicepNet.Core.Azure;
using System;
using System.Collections.Generic;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;

namespace BicepNet.Core;

public partial class BicepWrapper
{
    public IDictionary<string, string> ExportResources(string[] ids, string? configurationPath = null, bool includeTargetScope = false) =>
        joinableTaskFactory.Run(() => ExportResourcesAsync(ids, configurationPath, includeTargetScope));

    public async Task<IDictionary<string, string>> ExportResourcesAsync(string[] ids, string? configurationPath = null, bool includeTargetScope = false)
    {
        Dictionary<string, string> result = [];
        var taskList = new List<Task<(string resourceName, string template)>>();
        foreach (string id in ids)
        {
            taskList.Add(ExportResourceAsync(id, configurationPath, includeTargetScope));
        }
        foreach ((string name, string template) in await Task.WhenAll(taskList))
        {
            if(string.IsNullOrEmpty(name)) { continue; }
            result.Add(name, template);
        }

        return result;
    }

    private async Task<(string resourceName, string template)> ExportResourceAsync(string id, string? configurationPath = null, bool includeTargetScope = false)
    {
        var resourceId = AzureHelpers.ValidateResourceId(id);
        resourceId.Deconstruct(
            out _,
            out string fullyQualifiedType,
            out _,
            out _,
            out _
        );
        var matchedType = BicepHelper.ResolveBicepTypeDefinition(fullyQualifiedType, azResourceTypeLoader, logger);

        JsonElement resource;
        try
        {
            var cancellationToken = new CancellationToken();
            var config = configurationManager.GetConfiguration(new Uri(configurationPath ?? "inmemory://main.bicep"));
            resource = await azResourceProvider.GetGenericResource(config, resourceId, matchedType.ApiVersion, cancellationToken);
        }
        catch (Exception exception)
        {
            var message = $"Failed to fetch resource '{resourceId}' with API version {matchedType.ApiVersion}: {exception}";
            throw new InvalidOperationException(message);
        }

        if(resource.ValueKind == JsonValueKind.Null)
        {
            return ("", "");
        }

        string template = AzureResourceProvider.GenerateBicepTemplate(resourceId, matchedType, resource, includeTargetScope: includeTargetScope);
        template = RewriteBicepTemplate(template);
        var name = AzureHelpers.GetResourceFriendlyName(id);

        return (name, template);
    }
}