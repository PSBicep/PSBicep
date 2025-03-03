using System;
using System.Linq;
using Azure.Deployments.Core.Comparers;
using Bicep.Core.Resources;
using Bicep.Core.TypeSystem.Providers.Az;
using Microsoft.Extensions.Logging;

namespace PSBicep.Core;

internal static class BicepHelper
{
    internal static ResourceTypeReference ResolveBicepTypeDefinition(string fullyQualifiedType, AzResourceTypeLoader azResourceTypeLoader, ILogger? logger = null)
    {
        var matchedType = azResourceTypeLoader.GetAvailableTypes()
            .Where(x => StringComparer.OrdinalIgnoreCase.Equals(fullyQualifiedType, x.FormatType()))
            .OrderByDescending(x => x.ApiVersion ?? "", ApiVersionComparer.Instance)
            .FirstOrDefault();
        if (matchedType is null || matchedType.ApiVersion is null)
        {
            var message = $"Failed to find a Bicep type definition for resource of type \"{fullyQualifiedType}\".";
            logger?.LogCritical("{message}", message);
            throw new InvalidOperationException(message);
        }

        return matchedType;
    }

    internal static string[] GetApiVersions(ResourceTypeReference typeReference, AzResourceTypeLoader azResourceTypeLoader)
    {
        return azResourceTypeLoader.GetAvailableTypes()
            .Where(x => StringComparer.OrdinalIgnoreCase.Equals(typeReference.FormatType(), x.FormatType()))
            .Select(x => x.ApiVersion ?? "")
            .Where(x => !string.IsNullOrEmpty(x))
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .ToArray();
    }
}