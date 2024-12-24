using System;
using System.Text.Json;
using PSBicep.Core.Azure;

namespace PSBicep.Core;

public partial class BicepWrapper
{
    public string? ConvertResourceToBicep(string resourceId, string resourceBody, string? configurationPath = null, bool includeTargetScope = false, bool removeUnknownProperties = false)
    {
        var id = AzureHelpers.ValidateResourceId(resourceId);
        var matchedType = BicepHelper.ResolveBicepTypeDefinition(id.FullyQualifiedType, azResourceTypeLoader, logger: logger);
        JsonElement resource = JsonSerializer.Deserialize<JsonElement>(resourceBody);
        configurationManager.GetConfiguration(new Uri(configurationPath ?? "inmemory:///main.bicep"));
        return AzureResourceProvider.GenerateBicepTemplate(compiler, id, matchedType, resource, configuration, includeTargetScope, removeUnknownProperties);
    }
}
