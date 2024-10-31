using PSBicep.Core.Azure;
using System;
using System.Collections.Generic;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;

namespace PSBicep.Core;

public partial class BicepWrapper
{
    public IDictionary<string, string> ExportResources(string[] ids, string? configurationPath = null, bool includeTargetScope = false) =>
        joinableTaskFactory.Run(() => ExportResourcesAsync(ids, configurationPath, includeTargetScope));

    public async Task<IDictionary<string, string>> ExportResourcesAsync(string[] ids, string? configurationPath = null, bool includeTargetScope = false)
    {
        Dictionary<string, string> result = [];

        var cancellationToken = new CancellationToken();
        var config = configurationManager.GetConfiguration(new Uri(configurationPath ?? "inmemory://main.bicep"));
        var resourceDefinitions = azResourceProvider.GetResourcesAsync(config, ids, cancellationToken);

        await foreach (var (id, resource) in resourceDefinitions)
        {
            var name = AzureHelpers.GetResourceFriendlyName(id);
            var resourceId = AzureHelpers.ValidateResourceId(id);
            var matchedType = BicepHelper.ResolveBicepTypeDefinition(resourceId.FullyQualifiedType, azResourceTypeLoader, logger);
            result.Add(name, AzureResourceProvider.GenerateBicepTemplate(resourceId, matchedType, resource, includeTargetScope: includeTargetScope));
        }

        return result;
    }
}