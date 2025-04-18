using Bicep.Core.Resources;
using Bicep.Core.TypeSystem.Providers.Az;
using Microsoft.Extensions.Logging;
using PSBicep.Core.Azure;
using PSBicep.Core.Models;

namespace PSBicep.Core.Services;

public class BicepTypeResolver
{
    private readonly AzResourceTypeLoader _azResourceTypeLoader;
    private readonly ILogger _logger;

    public BicepTypeResolver(
        AzResourceTypeLoader azResourceTypeLoader,
        ILogger logger)
    {
        _azResourceTypeLoader = azResourceTypeLoader;
        _logger = logger;
    }

    public string ResolveBicepResourceType(string id)
    {
        var resourceId = AzureHelpers.ValidateResourceId(id);
        return BicepHelper.ResolveBicepTypeDefinition(resourceId.FullyQualifiedType, _azResourceTypeLoader, logger: _logger).ToString();
    }

    public string[] GetApiVersions(string resourceTypeReference)
    {
        return BicepHelper.GetApiVersions(ResourceTypeReference.Parse(resourceTypeReference), _azResourceTypeLoader);
    }
}