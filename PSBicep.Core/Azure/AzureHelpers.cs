using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Text.RegularExpressions;
using Azure.Core;
using Azure.Deployments.Core.Definitions.Identifiers;
using Bicep.Core;
using Bicep.Core.Configuration;
using Bicep.Core.Extensions;
using Bicep.Core.Parsing;
using Bicep.Core.PrettyPrintV2;
using Bicep.Core.Resources;
using Bicep.Core.Rewriters;
using Bicep.Core.Semantics;
using Bicep.Core.SourceGraph;
using Bicep.Core.Syntax;
using Bicep.LanguageServer.Providers;
using PSBicep.Core.Rewriters;

namespace PSBicep.Core.Azure;

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
        return string.Format("{0}_{1}", fullyQualifiedType.Replace(@"/", "-").ToLowerInvariant(), fullyQualifiedName.Replace(@"/", "-")).ToLowerInvariant();
    }

    public static string GenerateBicepTemplate(BicepCompiler compiler, IAzResourceProvider.AzResourceIdentifier resourceId, ResourceTypeReference resourceType, JsonElement resource, RootConfiguration configuration, bool includeTargetScope = false, bool removeUnknownProperties = false)
    {
        // Calculate target scope to be able to add it to the top of the template
        var resourceIdentifier = new ResourceIdentifier(resourceId.FullyQualifiedId);
        string targetScope = (resourceIdentifier.Parent?.ResourceType.ToString()) switch
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

        // Generate Bicep template
        var resourceDeclaration = AzureHelpers.CreateResourceSyntax(resource, resourceId, resourceType);
        var program = new ProgramSyntax(
            [resourceDeclaration],
            SyntaxFactory.EndOfFileToken);

        BicepSourceFile bicepFile = compiler.SourceFileFactory.CreateBicepFile(new Uri("inmemory:///generated.bicep"), program.ToString());

        var workspace = new Workspace();
        workspace.UpsertSourceFile(bicepFile);
        var compilation = compiler.CreateCompilationWithoutRestore(bicepFile.Uri, workspace);

        var rewriters = new List<Func<SemanticModel, SyntaxRewriteVisitor>>
        {
            model => new TypeCasingFixerRewriter(model),
            model => new ReadOnlyPropertyRemovalRewriter(model)
        };


        if (removeUnknownProperties == true)
        {
            rewriters.Add(model => new UnknownPropertyRemovalRewriter(model));
        }

        bicepFile = RewriterHelper.RewriteMultiple(
            compiler,
            compilation,
            bicepFile,
            rewritePasses: 5,
            [.. rewriters]);

        var template = PrettyPrinterV2.PrintValid(bicepFile.ProgramSyntax, configuration.Formatting.Data);

        return includeTargetScope ? targetScope + template : template;
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
            new SyntaxBase[] { description, SyntaxFactory.NewlineToken, },
            SyntaxFactory.ResourceKeywordToken,
            SyntaxFactory.CreateIdentifierWithTrailingSpace(GenerateValidIdentifier(resourceId.UnqualifiedName, resourceId.FullyQualifiedName)),
            SyntaxFactory.CreateStringLiteral(typeReference.FormatName()),
            null,
            SyntaxFactory.CreateToken(TokenType.Assignment),
            [],
            SyntaxFactory.CreateObject(properties));
    }

    private static string GenerateValidIdentifier(string unqualifiedName, string qualifiedName)
    {
        string identifier = UnifiedNamePattern().Replace(unqualifiedName, "");
        if (string.IsNullOrEmpty(identifier))
        {
            // Identifier must start with a letter
            qualifiedName = StartsWithNonLetter().Replace(qualifiedName, "");
            // Replace separators with underscores
            qualifiedName = qualifiedName.Replace("/", "_");
            // Remove any other invalid characters
            identifier = InvalidIdentifierChars().Replace(qualifiedName, "");
        }
        return identifier;
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
    private static partial Regex UnifiedNamePattern();
    [GeneratedRegex("^[^a-zA-Z]+")]
    private static partial Regex StartsWithNonLetter();
    [GeneratedRegex("[^a-zA-Z0-9_]")]
    private static partial Regex InvalidIdentifierChars();
}
