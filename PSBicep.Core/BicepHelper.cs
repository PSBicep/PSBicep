using System;
using System.Linq;
using Azure.Deployments.Core.Comparers;
using Bicep.Core.Resources;
using Bicep.Core.TypeSystem.Providers.Az;
using Microsoft.Extensions.Logging;

namespace PSBicep.Core;

internal static class BicepHelper
{
    internal static ResourceTypeReference[] GetResourceProviders(string providerName, AzResourceTypeLoader azResourceTypeLoader, bool exactMatch = false, ILogger? logger = null)
    {
        return [.. azResourceTypeLoader.GetAvailableTypes()
            .Where(x =>
                x.TypeSegments.Length == 2 &&
                (string.IsNullOrEmpty(providerName) || (exactMatch
                    ? x.TypeSegments[0].Equals(providerName, StringComparison.OrdinalIgnoreCase)
                    : x.TypeSegments[0].StartsWith(providerName, StringComparison.OrdinalIgnoreCase))))];
    }
    internal static string[] GetResourceProviderNames(string providerName, AzResourceTypeLoader azResourceTypeLoader, bool fullyQualified = false, bool exactMatch = false, ILogger? logger = null)
    {
        return [.. GetResourceProviders(providerName, azResourceTypeLoader, exactMatch, logger)
            .Select(x => fullyQualified ? x.FormatType() : x.TypeSegments[0])
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .OrderBy(x => x, StringComparer.OrdinalIgnoreCase)];
    }

    internal static ResourceTypeReference[] GetResourceTypes(string providerName, string typeName, AzResourceTypeLoader azResourceTypeLoader, bool exactMatch = false, ILogger? logger = null)
    {
        return [.. azResourceTypeLoader.GetAvailableTypes()
            .Where(x =>
                x.TypeSegments.Length == 2 &&
                (string.IsNullOrEmpty(providerName) || x.TypeSegments[0].Equals(providerName, StringComparison.OrdinalIgnoreCase)) &&
                (string.IsNullOrEmpty(typeName) || (exactMatch
                    ? x.TypeSegments[1].Equals(typeName, StringComparison.OrdinalIgnoreCase)
                    : x.TypeSegments[1].StartsWith(typeName, StringComparison.OrdinalIgnoreCase))))];
    }
    internal static string[] GetResourceTypeNames(string providerName, string typeName, AzResourceTypeLoader azResourceTypeLoader, bool fullyQualified = false, bool exactMatch = false, ILogger? logger = null)
    {
        return [.. GetResourceTypes(providerName, typeName, azResourceTypeLoader, exactMatch, logger)
            .Select(x => fullyQualified ? x.FormatType() : x.TypeSegments[1])
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .OrderBy(x => x, StringComparer.OrdinalIgnoreCase)];
    }

    internal static string[] GetResourceTypeNamesByPrefix(string prefix, AzResourceTypeLoader azResourceTypeLoader, bool includeVersion = false, bool recursive = false)
    {
        var prefixSegments = prefix.Count(c => c == '/') + 1;
        var prefixContainsVersion = prefix.Contains('@');

        return [.. azResourceTypeLoader.GetAvailableTypes()
            .Where(x => x.Name.StartsWith(prefix, StringComparison.OrdinalIgnoreCase))
            .SelectMany(x =>
            {
                if (prefixContainsVersion)
                {
                    return [x.Name];
                }

                if (recursive || prefixSegments == x.TypeSegments.Length)
                {
                    return includeVersion
                        ? new[] { x.Type, x.Type + '@' }
                        : [x.Type];
                }

                return [string.Join("/", x.TypeSegments.Take(prefixSegments)) + '/'];
            })
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .OrderBy(x => x, BicepHelper.ResourceTypeVersionComparer.Instance)
        ];
    }

    internal static ResourceTypeReference[] GetChildResourceTypes(string providerName, string typeName, string childTypeName, AzResourceTypeLoader azResourceTypeLoader, bool exactMatch = false, ILogger? logger = null)
    {
        return [.. azResourceTypeLoader.GetAvailableTypes()
            .Where(x =>
                x.TypeSegments.Length > 2 &&
                (string.IsNullOrEmpty(providerName) || x.TypeSegments[0].Equals(providerName, StringComparison.OrdinalIgnoreCase)) &&
                (string.IsNullOrEmpty(typeName) || x.TypeSegments[1].Equals(typeName, StringComparison.OrdinalIgnoreCase)) &&
                (string.IsNullOrEmpty(childTypeName) || (exactMatch
                    ? string.Join('/', x.TypeSegments[2..]).Equals(childTypeName, StringComparison.OrdinalIgnoreCase)
                    : string.Join('/', x.TypeSegments[2..]).StartsWith(childTypeName, StringComparison.OrdinalIgnoreCase))))];
    }

    internal static string[] GetChildResourceTypeNames(string providerName, string typeName, string childTypeName, AzResourceTypeLoader azResourceTypeLoader, bool fullyQualified = false, bool exactMatch = false, ILogger? logger = null)
    {
        return [.. GetChildResourceTypes(providerName, typeName, childTypeName, azResourceTypeLoader, exactMatch, logger)
            .Select(x => fullyQualified ? x.FormatType() : string.Join('/', x.TypeSegments[2..]))
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .OrderBy(x => x, StringComparer.OrdinalIgnoreCase)];
    }

    internal static ResourceTypeReference ResolveBicepTypeDefinition(string fullyQualifiedType, AzResourceTypeLoader azResourceTypeLoader, ILogger? logger = null, int skip = 0, bool avoidPreview = false)
    {
        var matchedType = GetBicepTypes(fullyQualifiedType, azResourceTypeLoader, logger, skip, avoidPreview)
            .FirstOrDefault();

        return matchedType!;
    }

    internal static ResourceTypeReference[] GetBicepTypes(string fullyQualifiedType, AzResourceTypeLoader azResourceTypeLoader, ILogger? logger = null, int skip = 0, bool avoidPreview = false)
    {
        var matchedTypes = azResourceTypeLoader.GetAvailableTypes()
            .Where(x => StringComparer.OrdinalIgnoreCase.Equals(fullyQualifiedType, x.FormatType()))
            .Where(x =>
                x.ApiVersion is not null &&
                (!avoidPreview || !x.ApiVersion.EndsWith("-preview", StringComparison.OrdinalIgnoreCase)))
            .OrderByDescending(x => x.ApiVersion!, ApiVersionComparer.Instance)
            .Skip(skip)
            .ToArray();

        if (matchedTypes.Length == 0)
        {
            if (logger is not null && logger.IsEnabled(LogLevel.Critical))
            {
                logger.LogCritical("Failed to find a Bicep type definition for resource of type \"{fullyQualifiedType}\".", fullyQualifiedType);
            }

            throw new InvalidOperationException($"Failed to find a Bicep type definition for resource of type \"{fullyQualifiedType}\".");
        }

        return matchedTypes;
    }

    internal static string[] GetApiVersions(ResourceTypeReference typeReference, AzResourceTypeLoader azResourceTypeLoader, ILogger? logger = null, int skip = 0, bool avoidPreview = false)
    {
        return [.. GetBicepTypes(typeReference.FormatType(), azResourceTypeLoader, logger, skip, avoidPreview)
            .Select(x => x.ApiVersion ?? "")
            .Where(x => !string.IsNullOrEmpty(x))
            .Distinct(StringComparer.OrdinalIgnoreCase)];
    }

    public sealed class ResourceTypeVersionComparer : StringComparer
    {
        public static ResourceTypeVersionComparer Instance { get; } = new();

        private ResourceTypeVersionComparer()
        {
        }

        private static (string Type, string Version) Split(string value)
        {
            var separator = value.LastIndexOf('@');
            return separator >= 0
                ? (value[..separator], value[(separator + 1)..])
                : (value, string.Empty);
        }

        public override int Compare(string? x, string? y)
        {
            if (ReferenceEquals(x, y)) return 0;
            if (x is null) return -1;
            if (y is null) return 1;

            var (xType, xVersion) = Split(x);
            var (yType, yVersion) = Split(y);

            // First compare type part in ascending order
            var typeComparison = string.Compare(xType, yType, StringComparison.OrdinalIgnoreCase);
            if (typeComparison != 0) return typeComparison;

            // Type is equal, compare version part in descending order
            return string.Compare(yVersion, xVersion, StringComparison.OrdinalIgnoreCase);
        }

        public override bool Equals(string? x, string? y)
            => Compare(x, y) == 0;

        public override int GetHashCode(string obj)
        {
            ArgumentNullException.ThrowIfNull(obj);

            var (type, version) = Split(obj);

            return HashCode.Combine(
                StringComparer.OrdinalIgnoreCase.GetHashCode(type),
                StringComparer.OrdinalIgnoreCase.GetHashCode(version));
        }
    }

}
