using Azure.Core;
using Azure.ResourceManager;
using System;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;

namespace BicepNet.Core.Azure;

internal static class ManagementGroupHelper
{
    public static async Task<JsonElement> GetManagementGroupAsync(ResourceIdentifier resourceIdentifier, ArmClient armClient, CancellationToken cancellationToken)
    {
        var mg = armClient.GetManagementGroupResource(resourceIdentifier);
        var mgResponse = await mg.GetAsync(cancellationToken: cancellationToken);
        if (mgResponse is null || mgResponse.GetRawResponse().ContentStream is not { } mgContentStream)
        {
            throw new InvalidOperationException($"Failed to fetch resource from Id '{resourceIdentifier}'");
        }
        mgContentStream.Position = 0;
        return await JsonSerializer.DeserializeAsync<JsonElement>(mgContentStream, cancellationToken: cancellationToken);
    }

    public static async IAsyncEnumerable<string> GetManagementGroupDescendantsAsync(ResourceIdentifier resourceIdentifier, ArmClient armClient, [EnumeratorCancellation] CancellationToken cancellationToken)
    {
        var mg = armClient.GetManagementGroupResource(resourceIdentifier);
        var list = mg.GetDescendantsAsync(cancellationToken: cancellationToken);

        await foreach (var item in list)
        {
            if (item.ParentId != resourceIdentifier) { continue; }
            if (item.ResourceType == "Microsoft.Management/managementGroups/subscriptions")
            {
                var subId = $"{mg.Id}/subscriptions/{item.Name}";
                yield return subId;
            } else
            {
                yield return item.Id.ToString();
            }
        }
    }
}