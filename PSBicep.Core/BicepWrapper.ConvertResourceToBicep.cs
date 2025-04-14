using System.Collections;
using System.Collections.Generic;
using System.Text.Json;
using System.Threading.Tasks;
using Bicep.Core.FileSystem;
using PSBicep.Core.Azure;

namespace PSBicep.Core;

public partial class BicepWrapper
{

    public (string, string?) ConvertResourceToBicep(string resourceId, string resourceBody, string configurationPath, bool includeTargetScope = false, bool removeUnknownProperties = false) =>
        joinableTaskFactory.Run(() => ConvertResourceToBicepAsync(resourceId, resourceBody, configurationPath, includeTargetScope, removeUnknownProperties));

    public async Task<(string, string?)> ConvertResourceToBicepAsync(string resourceId, string resourceBody, string configurationPath, bool includeTargetScope = false, bool removeUnknownProperties = false)
    {
        var id = AzureHelpers.ValidateResourceId(resourceId);
        var matchedType = BicepHelper.ResolveBicepTypeDefinition(id.FullyQualifiedType, azResourceTypeLoader, logger: logger);
        JsonElement resource = JsonSerializer.Deserialize<JsonElement>(resourceBody);
        var configuration = configurationManager.GetConfiguration(PathHelper.FilePathToFileUrl(configurationPath));
        var template = await Task.Run(() => AzureHelpers.GenerateBicepTemplate(compiler, id, matchedType, resource, configuration, includeTargetScope, removeUnknownProperties));
        return (resourceId, template);
    }

    public Hashtable ConvertResourceToBicep(Hashtable resourceDictionary, string configurationPath, bool includeTargetScope = false, bool removeUnknownProperties = false) =>
        joinableTaskFactory.Run(() => ConvertResourceToBicepAsync(resourceDictionary, configurationPath, includeTargetScope, removeUnknownProperties));

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
}
