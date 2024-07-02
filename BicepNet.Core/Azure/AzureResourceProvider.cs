using Azure.Core;
using Azure.ResourceManager;
using Bicep.Core.Configuration;
using Bicep.Core.Diagnostics;
using Bicep.Core.Parsing;
using Bicep.Core.PrettyPrint;
using Bicep.Core.PrettyPrint.Options;
using Bicep.Core.Registry.Auth;
using Bicep.Core.Resources;
using Bicep.Core.Syntax;
using Bicep.LanguageServer.Providers;
using System;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;

namespace BicepNet.Core.Azure;
public class AzureResourceProvider(ITokenCredentialFactory credentialFactory) : IAzResourceProvider
{
    private readonly ITokenCredentialFactory credentialFactory = credentialFactory;
    private AccessToken accessToken;

    private async Task UpdateAccessTokenAsync(RootConfiguration configuration, CancellationToken cancellationToken)
    {
        var credential = credentialFactory.CreateChain(configuration.Cloud.CredentialPrecedence, null, configuration.Cloud.ActiveDirectoryAuthorityUri);
        var tokenRequestContext = new TokenRequestContext([configuration.Cloud.AuthenticationScope], configuration.Cloud.ResourceManagerEndpointUri.ToString());
        accessToken = await credential.GetTokenAsync(tokenRequestContext, cancellationToken);
    }

    private ArmClient CreateArmClient(RootConfiguration configuration, string subscriptionId, (string resourceType, string? apiVersion) resourceTypeApiVersionMapping)
    {
        var options = new ArmClientOptions
        {
            Environment = new ArmEnvironment(configuration.Cloud.ResourceManagerEndpointUri, configuration.Cloud.AuthenticationScope)
        };
        if (resourceTypeApiVersionMapping.apiVersion is not null)
        {
            options.SetApiVersion(new ResourceType(resourceTypeApiVersionMapping.resourceType), resourceTypeApiVersionMapping.apiVersion);
        }

        var credential = credentialFactory.CreateChain(configuration.Cloud.CredentialPrecedence, null, configuration.Cloud.ActiveDirectoryAuthorityUri);

        return new ArmClient(credential, subscriptionId, options);
    }

    public async IAsyncEnumerable<(string, JsonElement)> GetChildResourcesAsync(RootConfiguration configuration, IAzResourceProvider.AzResourceIdentifier scopeResourceId, [EnumeratorCancellation] CancellationToken cancellationToken)
    {
        (string resourceType, string? apiVersion) resourceTypeApiVersionMapping = (scopeResourceId.FullyQualifiedType, null);

        if (string.IsNullOrEmpty(accessToken.Token) || accessToken.ExpiresOn.UtcDateTime < DateTimeOffset.UtcNow.AddMinutes(10))
        {
            await UpdateAccessTokenAsync(configuration, cancellationToken);
        }

        var armClient = CreateArmClient(configuration, scopeResourceId.subscriptionId, resourceTypeApiVersionMapping);
        var scopeResourceIdentifier = new ResourceIdentifier(scopeResourceId.FullyQualifiedId);

        List<Task<IDictionary<string, JsonElement>>> tasks = [];

        switch ((string)scopeResourceIdentifier.ResourceType)
        {
            case "Microsoft.Management/managementGroups":
                var resourceIdList = ManagementGroupHelper.GetManagementGroupDescendantsAsync(scopeResourceIdentifier, armClient, cancellationToken);
                await foreach (string id in resourceIdList)
                {
                    var resourceId = AzureHelpers.ValidateResourceId(id);
                    var resource = await GetGenericResource(configuration, resourceId, null, cancellationToken: cancellationToken);
                    yield return (id, resource);
                }

                // Setup tasks of all dictionaries to loop through
                tasks = [
                    PolicyHelper.ListPolicyDefinitionsAsync(scopeResourceIdentifier, armClient, cancellationToken),
                    PolicyHelper.ListPolicyInitiativesAsync(scopeResourceIdentifier, armClient, cancellationToken),
                    PolicyHelper.ListPolicyAssignmentsAsync(scopeResourceIdentifier, armClient, cancellationToken),
                    RoleHelper.ListRoleAssignmentsAsync(scopeResourceIdentifier, armClient, cancellationToken),
                    RoleHelper.ListRoleDefinitionsAsync(scopeResourceIdentifier, armClient, RoleDefinitionType.CustomRole, cancellationToken)
                ];
                break;
            case "Microsoft.Resources/subscriptions":
                tasks = [
                    PolicyHelper.ListPolicyDefinitionsAsync(scopeResourceIdentifier, armClient, cancellationToken),
                    PolicyHelper.ListPolicyInitiativesAsync(scopeResourceIdentifier, armClient, cancellationToken),
                    PolicyHelper.ListPolicyAssignmentsAsync(scopeResourceIdentifier, armClient, cancellationToken),
                    RoleHelper.ListRoleAssignmentsAsync(scopeResourceIdentifier, armClient, cancellationToken),
                    RoleHelper.ListRoleDefinitionsAsync(scopeResourceIdentifier, armClient, RoleDefinitionType.CustomRole, cancellationToken)
                ];
                break;
            case "Microsoft.Resources/resourceGroups":
                tasks = [
                    PolicyHelper.ListPolicyAssignmentsAsync(scopeResourceIdentifier, armClient, cancellationToken),
                    RoleHelper.ListRoleAssignmentsAsync(scopeResourceIdentifier, armClient, cancellationToken)
                ];
                break;
        }
        // Return all resources found
        foreach (var task in tasks)
        {
            foreach (var entry in await task)
            {
                yield return (entry.Key, entry.Value);
            }
        }
    }
    
    public async Task<JsonElement> GetGenericResource(RootConfiguration configuration, IAzResourceProvider.AzResourceIdentifier resourceId, string? apiVersion, CancellationToken cancellationToken)
    {
        (string resourceType, string? apiVersion) resourceTypeApiVersionMapping = (resourceId.FullyQualifiedType, apiVersion);

        var armClient = CreateArmClient(configuration, resourceId.subscriptionId, resourceTypeApiVersionMapping);
        var resourceIdentifier = new ResourceIdentifier(resourceId.FullyQualifiedId);
        
        switch (resourceIdentifier.ResourceType)
        {
            case "Microsoft.Management/managementGroups":
                return await ManagementGroupHelper.GetManagementGroupAsync(resourceIdentifier, armClient, cancellationToken);
            case "Microsoft.Authorization/policyDefinitions":
                return await PolicyHelper.GetPolicyDefinitionAsync(resourceIdentifier, armClient, cancellationToken);
            case "Microsoft.Resources/subscriptions":
                return await SubscriptionHelper.GetSubscriptionAsync(resourceIdentifier, armClient, cancellationToken);
            case "Microsoft.Authorization/roleAssignments":
                return await RoleHelper.GetRoleAssignmentAsync(resourceIdentifier, armClient, cancellationToken);
            case "Microsoft.Authorization/roleDefinitions":
                return await RoleHelper.GetRoleDefinitionAsync(resourceIdentifier, armClient, cancellationToken);
            case "Microsoft.Management/managementGroups/subscriptions":
                if (string.IsNullOrEmpty(accessToken.Token))
                {
                    await UpdateAccessTokenAsync(configuration, cancellationToken);
                }
                return await SubscriptionHelper.GetManagementGroupSubscriptionAsync(resourceIdentifier, accessToken, cancellationToken);
            default:
                var genericResourceResponse = await armClient.GetGenericResource(resourceIdentifier).GetAsync(cancellationToken);
                if (genericResourceResponse is null ||
                    genericResourceResponse.GetRawResponse().ContentStream is not { } contentStream)
                {
                    throw new InvalidOperationException($"Failed to fetch resource from Id '{resourceId.FullyQualifiedId}'");
                }

                contentStream.Position = 0;
                return await JsonSerializer.DeserializeAsync<JsonElement>(contentStream, cancellationToken: cancellationToken);
        }
    }
    
    public static string GenerateBicepTemplate(IAzResourceProvider.AzResourceIdentifier resourceId, ResourceTypeReference resourceType, JsonElement resource, bool includeTargetScope = false)
    {
        var resourceIdentifier = new ResourceIdentifier(resourceId.FullyQualifiedId);
        string targetScope = (string?)(resourceIdentifier.Parent?.ResourceType) switch
        {
            "Microsoft.Resources/resourceGroups" => $"targetScope = 'resourceGroup'{Environment.NewLine}",
            "Microsoft.Resources/subscriptions" => $"targetScope = 'subscription'{Environment.NewLine}",
            "Microsoft.Management/managementGroups" => $"targetScope = 'managementGroup'{Environment.NewLine}",
            _ => $"targetScope = 'tenant'{Environment.NewLine}",
        };
        if (resourceIdentifier.ResourceType == "Microsoft.Management/managementGroups" || resourceIdentifier.ResourceType == "Microsoft.Management/managementGroups/subscriptions")
        {
            targetScope = $"targetScope = 'tenant'{Environment.NewLine}";
        }

        var resourceDeclaration = AzureHelpers.CreateResourceSyntax(resource, resourceId, resourceType);

        var printOptions = new PrettyPrintOptions(NewlineOption.LF, IndentKindOption.Space, 2, false);
        var program = new ProgramSyntax(
            [resourceDeclaration],
            SyntaxFactory.CreateToken(TokenType.EndOfFile));
        var template = PrettyPrinter.PrintProgram(program, printOptions, EmptyDiagnosticLookup.Instance, EmptyDiagnosticLookup.Instance);

        return includeTargetScope ? targetScope + template : template;
    }
}