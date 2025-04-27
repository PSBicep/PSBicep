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
        var matchedType = GetApiVersions(fullyQualifiedType, azResourceTypeLoader, logger, skip, avoidPreview)
            .FirstOrDefault();

        if (matchedType is null || matchedType.ApiVersion is null)
        {
            var message = $"Failed to find a Bicep type definition for resource of type \"{fullyQualifiedType}\".";
            logger?.LogCritical("{message}", message);
            throw new InvalidOperationException(message);
        }

        return matchedType;
    }

    internal static IEnumerable<ResourceTypeReference> GetApiVersions(string fullyQualifiedType, AzResourceTypeLoader azResourceTypeLoader, ILogger? logger = null, int skip = 0, bool avoidPreview = false)
    {
        var allMatchedTypes = azResourceTypeLoader.GetAvailableTypes()
            .Where(x => StringComparer.OrdinalIgnoreCase.Equals(fullyQualifiedType, x.FormatType()))
            .Where(x => x.ApiVersion is not null);

        if (avoidPreview)
        {
            var NonPreviewMatchedTypes = allMatchedTypes
                .Where(x => !x.ApiVersion!.EndsWith("-preview", StringComparison.OrdinalIgnoreCase));

            if (NonPreviewMatchedTypes.Any())
            {
                allMatchedTypes = NonPreviewMatchedTypes;
            }
        }

        if (skip > 0 && allMatchedTypes.Count() > skip)
        {
            allMatchedTypes = allMatchedTypes.Take(skip);
        }

        var orderedType = allMatchedTypes
            .OrderByDescending(x => x.ApiVersion ?? "", ApiVersionComparer.Instance);

        if (orderedType is null)
        {
            var message = $"Failed to find a Bicep type definition for resource of type \"{fullyQualifiedType}\".";
            logger?.LogCritical("{message}", message);
            throw new InvalidOperationException(message);
        }

        return orderedType;
    }

    internal static string[] GetApiVersions(ResourceTypeReference typeReference, AzResourceTypeLoader azResourceTypeLoader, int skip = 0, bool avoidPreview = false)
    {
        return azResourceTypeLoader.GetAvailableTypes()
            .Where(x => StringComparer.OrdinalIgnoreCase.Equals(typeReference.FormatType(), x.FormatType()))
            .Select(x => x.ApiVersion ?? "")
            .Where(x => !string.IsNullOrEmpty(x))
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .ToArray();
    }
}