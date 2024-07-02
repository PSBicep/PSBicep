using Azure.Deployments.Core.Definitions.Identifiers;
using Bicep.Core.Parsing;
using Bicep.Core.Resources;
using Bicep.Core.Syntax;
using Bicep.LanguageServer.Providers;
using System;
using System.Collections.Generic;
using System.Collections.Immutable;
using System.Linq;
using System.Text.Json;
using System.Text.RegularExpressions;

namespace BicepNet.Core.Azure;

public static partial class AzureHelpers
{

    [GeneratedRegex(@"^/subscriptions/(?<subId>[^/]+)/resourceGroups/(?<rgName>[^/]+)$", RegexOptions.IgnoreCase | RegexOptions.ExplicitCapture | RegexOptions.CultureInvariant)]
    private static partial Regex ResourceGroupId();

    [GeneratedRegex(@"^/subscriptions/(?<subId>[^/]+)$", RegexOptions.IgnoreCase | RegexOptions.ExplicitCapture | RegexOptions.CultureInvariant)]
    private static partial Regex SubscriptionId();

    public static IAzResourceProvider.AzResourceIdentifier ValidateResourceId(string id)
    {
        if (TryParseResourceId(id) is not { } resourceId)
        {
            var message = $"Failed to parse supplied resourceId \"{id}\".";
            throw new InvalidOperationException(message);
        }
        return resourceId;
    }

    public static string GetResourceFriendlyName(string id)
    {
        var resourceId = ValidateResourceId(id);
        resourceId.Deconstruct(
            out _,
            out string fullyQualifiedType,
            out string fullyQualifiedName,
            out _,
            out _
        );
        return string.Format("{0}_{1}", fullyQualifiedType.Replace(@"/", "_"), fullyQualifiedName.Replace(@"/", "")).ToLowerInvariant();
    }

    // Private method originally copied from InsertResourceHandler.cs
    internal static IAzResourceProvider.AzResourceIdentifier? TryParseResourceId(string? resourceIdString)
    {
        if (resourceIdString is null)
        {
            return null;
        }

        if (ResourceId.TryParse(resourceIdString, out var resourceId))
        {
            return new(
                resourceId.FullyQualifiedId,
                resourceId.FormatFullyQualifiedType(),
                resourceId.FormatName(),
                resourceId.NameHierarchy.Last(),
                string.Empty);
        }

        var rgRegexMatch = ResourceGroupId().Match(resourceIdString);
        if (rgRegexMatch.Success)
        {
            return new(
                resourceIdString,
                "Microsoft.Resources/resourceGroups",
                rgRegexMatch.Groups["rgName"].Value,
                rgRegexMatch.Groups["rgName"].Value,
                rgRegexMatch.Groups["subId"].Value);
        }

        var subRegexMatch = SubscriptionId().Match(resourceIdString);
        if (subRegexMatch.Success)
        {
            IAzResourceProvider.AzResourceIdentifier resource = new(
                resourceIdString,
                "Microsoft.Management/managementGroups/subscriptions",
                subRegexMatch.Groups["subId"].Value,
                subRegexMatch.Groups["subId"].Value,
                subRegexMatch.Groups["subId"].Value);
            return resource;
        }

        return null;
    }

    // Private method originally copied from InsertResourceHandler.cs
    internal static ResourceDeclarationSyntax CreateResourceSyntax(JsonElement resource, IAzResourceProvider.AzResourceIdentifier resourceId, ResourceTypeReference typeReference)
    {
        var properties = new List<ObjectPropertySyntax>();
        foreach (var property in resource.EnumerateObject())
        {
            switch (property.Name.ToLowerInvariant())
            {
                case "id":
                case "type":
                case "apiVersion":
                    // Don't add these to the resource properties - they're part of the resource declaration.
                    break;
                case "name":
                    // Use the fully-qualified name instead of the name returned by the RP.
                    properties.Add(SyntaxFactory.CreateObjectProperty(
                        "name",
                        SyntaxFactory.CreateStringLiteral(resourceId.FullyQualifiedName)));
                    break;
                default:
                    properties.Add(SyntaxFactory.CreateObjectProperty(
                        property.Name,
                        ConvertJsonElement(property.Value)));
                    break;
            }
        }

        var description = SyntaxFactory.CreateDecorator(
            "description",
            SyntaxFactory.CreateStringLiteral($"Generated from {resourceId.FullyQualifiedId}"));

        return new ResourceDeclarationSyntax(
            [description, SyntaxFactory.NewlineToken,],
            SyntaxFactory.CreateIdentifierToken("resource"),
            SyntaxFactory.CreateIdentifier(NotLetters().Replace(resourceId.UnqualifiedName, "")),
            SyntaxFactory.CreateStringLiteral(typeReference.FormatName()),
            null,
            SyntaxFactory.CreateToken(TokenType.Assignment),
            [],
            SyntaxFactory.CreateObject(properties));
    }

    // Private method originally copied from InsertResourceHandler.cs
    private static SyntaxBase ConvertJsonElement(JsonElement element)
    {
        switch (element.ValueKind)
        {
            case JsonValueKind.Object:
                var properties = new List<ObjectPropertySyntax>();
                foreach (var property in element.EnumerateObject())
                {
                    properties.Add(SyntaxFactory.CreateObjectProperty(property.Name, ConvertJsonElement(property.Value)));
                }
                return SyntaxFactory.CreateObject(properties);
            case JsonValueKind.Array:
                var items = new List<SyntaxBase>();
                foreach (var value in element.EnumerateArray())
                {
                    items.Add(ConvertJsonElement(value));
                }
                return SyntaxFactory.CreateArray(items);
            case JsonValueKind.String:
                return SyntaxFactory.CreateStringLiteral(element.GetString()!);
            case JsonValueKind.Number:
                if (element.TryGetInt64(out long intValue))
                {
                    return SyntaxFactory.CreatePositiveOrNegativeInteger(intValue);
                }

                return SyntaxFactory.CreateFunctionCall(
                    "json",
                    SyntaxFactory.CreateStringLiteral(element.ToString()));
            case JsonValueKind.True:
                return SyntaxFactory.CreateToken(TokenType.TrueKeyword);
            case JsonValueKind.False:
                return SyntaxFactory.CreateToken(TokenType.FalseKeyword);
            case JsonValueKind.Null:
                return SyntaxFactory.CreateToken(TokenType.NullKeyword);
            default:
                throw new InvalidOperationException($"Failed to deserialize JSON");
        }
    }

    [GeneratedRegex("[^a-zA-Z]")]
    private static partial Regex NotLetters();
}
