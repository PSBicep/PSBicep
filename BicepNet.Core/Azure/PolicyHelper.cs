using Azure;
using Azure.Core;
using Azure.ResourceManager;
using Azure.ResourceManager.Resources;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;

namespace BicepNet.Core.Azure;

internal static class PolicyHelper
{
    public static async Task<IDictionary<string, JsonElement>> ListPolicyDefinitionsAsync(ResourceIdentifier scopeResourceId, ArmClient armClient, CancellationToken cancellationToken)
    {
        return (string)scopeResourceId.ResourceType switch
        {
            "Microsoft.Management/managementGroups" => await ListManagementGroupPolicyDefinitionAsync(scopeResourceId, armClient, cancellationToken),
            "Microsoft.Resources/subscriptions" => await ListSubscriptionPolicyDefinitionAsync(scopeResourceId, armClient, cancellationToken),
            _ => throw new InvalidOperationException($"Failed to list PolicyDefinitions on scope '{scopeResourceId}' with type '{scopeResourceId.ResourceType}"),
        };
    }

    public static async Task<IDictionary<string, JsonElement>> ListPolicyInitiativesAsync(ResourceIdentifier scopeResourceId, ArmClient armClient, CancellationToken cancellationToken)
    {
        return (string)scopeResourceId.ResourceType switch
        {
            "Microsoft.Management/managementGroups" => await ListManagementGroupPolicyInitiativeAsync(scopeResourceId, armClient, cancellationToken),
            "Microsoft.Resources/subscriptions" => await ListSubscriptionPolicyInitiativeAsync(scopeResourceId, armClient, cancellationToken),
            _ => throw new InvalidOperationException($"Failed to list PolicyDefinitions on scope '{scopeResourceId}' with type '{scopeResourceId.ResourceType}"),
        };
    }

    public static async Task<IDictionary<string, JsonElement>> ListPolicyAssignmentsAsync(ResourceIdentifier scopeResourceId, ArmClient armClient, CancellationToken cancellationToken)
    {
        return (string)scopeResourceId.ResourceType switch
        {
            "Microsoft.Management/managementGroups" => await ListManagementGroupPolicyAssignmentAsync(scopeResourceId, armClient, cancellationToken),
            "Microsoft.Resources/subscriptions" => await ListSubscriptionPolicyAssignmentAsync(scopeResourceId, armClient, cancellationToken),
            "Microsoft.Resources/resourceGroups" => await ListResourceGroupPolicyAssignmentAsync(scopeResourceId, armClient, cancellationToken),
            _ => throw new InvalidOperationException($"Failed to list PolicyDefinitions on scope '{scopeResourceId}' with type '{scopeResourceId.ResourceType}"),
        };
    }

    private static async Task<IDictionary<string, JsonElement>> ListManagementGroupPolicyDefinitionAsync(ResourceIdentifier resourceIdentifier, ArmClient armClient, CancellationToken cancellationToken)
    {
        var result = new Dictionary<string, JsonElement>();
        var mg = armClient.GetManagementGroupResource(resourceIdentifier);

        var collection = mg.GetManagementGroupPolicyDefinitions();
        var list = collection.GetAllAsync(filter: "atExactScope()", cancellationToken: cancellationToken);

        JsonElement element;

        var taskList = new Dictionary<string, Task<Response<ManagementGroupPolicyDefinitionResource>>>();
        await foreach (var item in list)
        {
            taskList.Add(item.Id.ToString(), item.GetAsync(cancellationToken: cancellationToken));
        }

        var responseList = await GetResponseDictionaryAsync(taskList);

        foreach (var id in responseList.Keys)
        {
            var policyItemResponse = responseList[id];
            var resourceId = AzureHelpers.ValidateResourceId(id);
            if (policyItemResponse is null ||
                policyItemResponse.GetRawResponse().ContentStream is not { } contentStream)
            {
                throw new InvalidOperationException($"Failed to fetch resource from Id '{resourceId.FullyQualifiedId}'");
            }
            contentStream.Position = 0;
            element = await JsonSerializer.DeserializeAsync<JsonElement>(contentStream, cancellationToken: cancellationToken);
            result.Add(id, element);
        }
        return result;
    }

    private static async Task<IDictionary<string, JsonElement>> ListManagementGroupPolicyInitiativeAsync(ResourceIdentifier resourceIdentifier, ArmClient armClient, CancellationToken cancellationToken)
    {
        var result = new Dictionary<string, JsonElement>();
        var mg = armClient.GetManagementGroupResource(resourceIdentifier);

        var collection = mg.GetManagementGroupPolicySetDefinitions();
        var list = collection.GetAllAsync(filter: "atExactScope()", cancellationToken: cancellationToken);

        JsonElement element;

        var taskList = new Dictionary<string, Task<Response<ManagementGroupPolicySetDefinitionResource>>>();
        await foreach (var item in list)
        {
            taskList.Add(item.Id.ToString(), item.GetAsync(cancellationToken: cancellationToken));
        }
        var responseList = await GetResponseDictionaryAsync(taskList);
        foreach (var id in responseList.Keys)
        {
            var policyItemResponse = responseList[id];
            var resourceId = AzureHelpers.ValidateResourceId(id);
            if (policyItemResponse is null ||
                policyItemResponse.GetRawResponse().ContentStream is not { } contentStream)
            {
                throw new InvalidOperationException($"Failed to fetch resource from Id '{resourceId.FullyQualifiedId}'");
            }
            contentStream.Position = 0;
            element = await JsonSerializer.DeserializeAsync<JsonElement>(contentStream, cancellationToken: cancellationToken);
            result.Add(id, element);
        }
        return result;
    }

    private static async Task<IDictionary<string, JsonElement>> ListSubscriptionPolicyDefinitionAsync(ResourceIdentifier resourceIdentifier, ArmClient armClient, CancellationToken cancellationToken)
    {
        var result = new Dictionary<string, JsonElement>();
        var sub = armClient.GetSubscriptionResource(resourceIdentifier);

        var collection = sub.GetSubscriptionPolicyDefinitions();
        var list = collection.GetAllAsync(filter: "atExactScope()", cancellationToken: cancellationToken);

        JsonElement element;

        var taskList = new Dictionary<string, Task<Response<SubscriptionPolicyDefinitionResource>>>();
        await foreach (var item in list)
        {
            taskList.Add(item.Id.ToString(), item.GetAsync(cancellationToken: cancellationToken));
        }
        var responseList = await GetResponseDictionaryAsync(taskList);
        foreach (var id in responseList.Keys)
        {
            var policyItemResponse = responseList[id];
            var resourceId = AzureHelpers.ValidateResourceId(id);
            if (policyItemResponse is null ||
                policyItemResponse.GetRawResponse().ContentStream is not { } contentStream)
            {
                throw new InvalidOperationException($"Failed to fetch resource from Id '{resourceId.FullyQualifiedId}'");
            }
            contentStream.Position = 0;
            element = await JsonSerializer.DeserializeAsync<JsonElement>(contentStream, cancellationToken: cancellationToken);
            result.Add(id, element);
        }
        return result;
    }

    private static async Task<IDictionary<string, JsonElement>> ListSubscriptionPolicyInitiativeAsync(ResourceIdentifier resourceIdentifier, ArmClient armClient, CancellationToken cancellationToken)
    {
        var result = new Dictionary<string, JsonElement>();
        var sub = armClient.GetSubscriptionResource(resourceIdentifier);

        var collection = sub.GetSubscriptionPolicySetDefinitions();
        var list = collection.GetAllAsync(filter: "atExactScope()", cancellationToken: cancellationToken);

        JsonElement element;

        var taskList = new Dictionary<string, Task<Response<SubscriptionPolicySetDefinitionResource>>>();
        await foreach (var item in list)
        {
            taskList.Add(item.Id.ToString(), item.GetAsync(cancellationToken: cancellationToken));
        }
        var responseList = await GetResponseDictionaryAsync(taskList);
        foreach (var id in responseList.Keys)
        {
            var policyItemResponse = responseList[id];
            var resourceId = AzureHelpers.ValidateResourceId(id);
            if (policyItemResponse is null ||
                policyItemResponse.GetRawResponse().ContentStream is not { } contentStream)
            {
                throw new InvalidOperationException($"Failed to fetch resource from Id '{resourceId.FullyQualifiedId}'");
            }
            contentStream.Position = 0;
            element = await JsonSerializer.DeserializeAsync<JsonElement>(contentStream, cancellationToken: cancellationToken);
            result.Add(id, element);
        }
        return result;
    }

    private static async Task<IDictionary<string, JsonElement>> ListManagementGroupPolicyAssignmentAsync(ResourceIdentifier resourceIdentifier, ArmClient armClient, CancellationToken cancellationToken)
    {
        var mg = armClient.GetManagementGroupResource(resourceIdentifier);
        var collection = mg.GetPolicyAssignments();

        return await ListPolicyAssignmentAsync(collection, cancellationToken);
    }

    private static async Task<IDictionary<string, JsonElement>> ListSubscriptionPolicyAssignmentAsync(ResourceIdentifier resourceIdentifier, ArmClient armClient, CancellationToken cancellationToken)
    {
        var sub = armClient.GetSubscriptionResource(resourceIdentifier);
        var collection = sub.GetPolicyAssignments();

        return await ListPolicyAssignmentAsync(collection, cancellationToken);
    }

    private static async Task<IDictionary<string, JsonElement>> ListResourceGroupPolicyAssignmentAsync(ResourceIdentifier resourceIdentifier, ArmClient armClient, CancellationToken cancellationToken)
    {
        var rg = armClient.GetResourceGroupResource(resourceIdentifier);
        var collection = rg.GetPolicyAssignments();

        return await ListPolicyAssignmentAsync(collection, cancellationToken);
    }

    private static async Task<IDictionary<string, JsonElement>> ListPolicyAssignmentAsync(PolicyAssignmentCollection collection, CancellationToken cancellationToken)
    {
        var result = new Dictionary<string, JsonElement>();
        var list = collection.GetAllAsync(filter: "atExactScope()", cancellationToken: cancellationToken);

        JsonElement element;

        var taskList = new Dictionary<string, Task<Response<PolicyAssignmentResource>>>();
        await foreach (var item in list)
        {
            taskList.Add(item.Id.ToString(), item.GetAsync(cancellationToken: cancellationToken));
        }
        var responseList = await GetResponseDictionaryAsync(taskList);
        foreach (var id in responseList.Keys)
        {
            var policyItemResponse = responseList[id];
            var resourceId = AzureHelpers.ValidateResourceId(id);
            if (policyItemResponse is null ||
                policyItemResponse.GetRawResponse().ContentStream is not { } contentStream)
            {
                throw new InvalidOperationException($"Failed to fetch resource from Id '{resourceId.FullyQualifiedId}'");
            }
            contentStream.Position = 0;
            element = await JsonSerializer.DeserializeAsync<JsonElement>(contentStream, cancellationToken: cancellationToken);
            result.Add(id, element);
        }
        return result;
    }

    public static async Task<JsonElement> GetPolicyDefinitionAsync(ResourceIdentifier resourceIdentifier, ArmClient armClient, CancellationToken cancellationToken)
    {
        switch (resourceIdentifier.Parent?.ResourceType)
        {
            case "Microsoft.Resources/subscriptions":
                var subPolicyDef = armClient.GetSubscriptionPolicyDefinitionResource(resourceIdentifier);
                var subPolicyDefResponse = await subPolicyDef.GetAsync(cancellationToken);

                if (subPolicyDefResponse is null || subPolicyDefResponse.GetRawResponse().ContentStream is not { } subContentStream)
                {
                    throw new InvalidOperationException($"Failed to fetch resource from Id '{resourceIdentifier}'");
                }
                subContentStream.Position = 0;
                return await JsonSerializer.DeserializeAsync<JsonElement>(subContentStream, cancellationToken: cancellationToken);
            case "Microsoft.Management/managementGroups":
                var mgPolicyDef = armClient.GetManagementGroupPolicyDefinitionResource(resourceIdentifier);
                var mgPolicyDefResponse = await mgPolicyDef.GetAsync(cancellationToken);

                if (mgPolicyDefResponse is null || mgPolicyDefResponse.GetRawResponse().ContentStream is not { } mgContentStream)
                {
                    throw new InvalidOperationException($"Failed to fetch resource from Id '{resourceIdentifier}'");
                }
                mgContentStream.Position = 0;
                return await JsonSerializer.DeserializeAsync<JsonElement>(mgContentStream, cancellationToken: cancellationToken);
            case "Microsoft.Resources/tenants":
                var tenantPolicyDef = armClient.GetTenantPolicyDefinitionResource(resourceIdentifier);
                var tenantPolicyDefResponse = await tenantPolicyDef.GetAsync(cancellationToken);

                if (tenantPolicyDefResponse is null || tenantPolicyDefResponse.GetRawResponse().ContentStream is not { } tenantContentStream)
                {
                    throw new InvalidOperationException($"Failed to fetch resource from Id '{resourceIdentifier}'");
                }
                tenantContentStream.Position = 0;
                return await JsonSerializer.DeserializeAsync<JsonElement>(tenantContentStream, cancellationToken: cancellationToken);
            default:
                throw new InvalidOperationException($"Failed to fetch resource from Id '{resourceIdentifier}' and parent '{resourceIdentifier.Parent?.ResourceType}");
        }
    }

    public static async Task<JsonElement> GetPolicyAssignmentAsync(ResourceIdentifier resourceIdentifier, ArmClient armClient, CancellationToken cancellationToken)
    {
        var pa = armClient.GetPolicyAssignmentResource(resourceIdentifier);
        var paResponse = await pa.GetAsync(cancellationToken: cancellationToken);
        if (paResponse is null || paResponse.GetRawResponse().ContentStream is not { } paContentStream)
        {
            throw new InvalidOperationException($"Failed to fetch resource from Id '{resourceIdentifier}'");
        }
        paContentStream.Position = 0;
        return await JsonSerializer.DeserializeAsync<JsonElement>(paContentStream, cancellationToken: cancellationToken);
    }

    private static async Task<IDictionary<string, Response<T>>> GetResponseDictionaryAsync<T>(Dictionary<string, Task<Response<T>>> taskList)
    {
        var resultListPairs = await Task.WhenAll(taskList.Select(async result =>
            new { result.Key, Value = await result.Value }));
        return resultListPairs.ToDictionary(result => result.Key, result => result.Value);
    }
}