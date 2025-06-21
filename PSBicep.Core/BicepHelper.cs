using System;
using System.Collections.Generic;
using System.Linq;
using Azure.Deployments.Core.Comparers;
using Bicep.Core.Resources;
using Bicep.Core.TypeSystem.Providers.Az;
using Microsoft.Extensions.Logging;

namespace PSBicep.Core;

internal static class BicepHelper
{
    internal static ResourceTypeReference ResolveBicepTypeDefinition(string fullyQualifiedType, AzResourceTypeLoader azResourceTypeLoader, ILogger? logger = null, int skip = 0, bool avoidPreview = false)
    {
        var matchedType = GetBicepTypes(fullyQualifiedType, azResourceTypeLoader, logger, skip, avoidPreview)
            .FirstOrDefault();

        return matchedType!;
    }

    internal static IEnumerable<ResourceTypeReference> GetBicepTypes(string fullyQualifiedType, AzResourceTypeLoader azResourceTypeLoader, ILogger? logger = null, int skip = 0, bool avoidPreview = false)
    {
        var matchedTypes = azResourceTypeLoader.GetAvailableTypes()
            .Where(x => StringComparer.OrdinalIgnoreCase.Equals(fullyQualifiedType, x.FormatType()))
            .Where(x =>
                x.ApiVersion is not null &&
                (!avoidPreview || !x.ApiVersion.EndsWith("-preview", StringComparison.OrdinalIgnoreCase)))
            .OrderByDescending(x => x.ApiVersion!, ApiVersionComparer.Instance)
            .Skip(skip);

        if (matchedTypes is null)
        {
            var message = $"Failed to find a Bicep type definition for resource of type \"{fullyQualifiedType}\".";
            logger?.LogCritical("{message}", message);
            throw new InvalidOperationException(message);
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
}