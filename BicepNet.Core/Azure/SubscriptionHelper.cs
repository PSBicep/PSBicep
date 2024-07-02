using Azure.Core;
using Azure.ResourceManager;
using Azure.ResourceManager.Subscription;
using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Runtime.CompilerServices;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;

namespace BicepNet.Core.Azure;

internal static class SubscriptionHelper
{
    public static async Task<JsonElement> GetManagementGroupSubscriptionAsync(ResourceIdentifier resourceIdentifier, AccessToken accessToken, CancellationToken cancellationToken)
    {
        var Uri = $"https://management.azure.com/{resourceIdentifier}?api-version=2020-05-01";
        using HttpClient client = new();
        client.DefaultRequestHeaders.Accept.Clear();
        client.DefaultRequestHeaders.Accept.Add(
            new MediaTypeWithQualityHeaderValue("application/json"));
        client.DefaultRequestHeaders.Add("User-Agent", ".NET Foundation Repository Reporter");
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("bearer", accessToken.Token);//$"Bearer {accessToken.Token}";
        try
        {
            var json = await client.GetStringAsync(Uri,cancellationToken);
            return JsonDocument.Parse(json).RootElement;
        }
        catch (Exception e)
        {
            if (e.Message.EndsWith("404 (Not Found)."))
            {
                return default;
            }
            throw;
        }
    }

    public static async IAsyncEnumerable<JsonElement> ListManagementGroupSubscriptionsAsync(ResourceIdentifier resourceIdentifier, AccessToken accessToken, [EnumeratorCancellation] CancellationToken cancellationToken)
    {
        if (resourceIdentifier.ResourceType != "Microsoft.Management/managementGroups")
        {
            throw new ArgumentException("Invalid resource type, must be \"Microsoft.Management/managementGroups\"");
        }

        var Uri = $"https://management.azure.com/{resourceIdentifier}/subscriptions?api-version=2020-05-01";
        using HttpClient client = new();
        client.DefaultRequestHeaders.Accept.Clear();
        client.DefaultRequestHeaders.Accept.Add(
            new MediaTypeWithQualityHeaderValue("application/json"));
        client.DefaultRequestHeaders.Add("User-Agent", ".NET Foundation Repository Reporter");
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("bearer", accessToken.Token);

        var json = await client.GetStringAsync(Uri, cancellationToken);
        using var result = JsonDocument.Parse(json);
        foreach (JsonElement element in result.RootElement.EnumerateArray())
        {
            yield return element;
        }

    }

    public static async Task<JsonElement> GetSubscriptionAsync(ResourceIdentifier resourceIdentifier, ArmClient armClient, CancellationToken cancellationToken)
    {
        var subId = SubscriptionAliasResource.CreateResourceIdentifier(resourceIdentifier.SubscriptionId);
        var sub = armClient.GetSubscriptionAliasResource(subId);

        var subResponse = await sub.GetAsync(cancellationToken: cancellationToken);
        if (subResponse is null || subResponse.GetRawResponse().ContentStream is not { } subContentStream)
        {
            throw new InvalidOperationException($"Failed to fetch resource from Id '{resourceIdentifier}'");
        }
        subContentStream.Position = 0;
        return await JsonSerializer.DeserializeAsync<JsonElement>(subContentStream, cancellationToken: cancellationToken);
    }

}