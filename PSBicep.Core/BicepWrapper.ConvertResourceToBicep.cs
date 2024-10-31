using Bicep.Core;
using Bicep.Core.Configuration;
using Bicep.Core.Extensions;
using Bicep.Core.Parsing;
using Bicep.Core.PrettyPrint;
using Bicep.Core.PrettyPrint.Options;
using Bicep.Core.PrettyPrintV2;
using Bicep.Core.Resources;
using Bicep.Core.Rewriters;
using Bicep.Core.Semantics;
using Bicep.Core.Syntax;
using Bicep.Core.Workspaces;
using Bicep.LanguageServer.Providers;
using PSBicep.Core.Azure;
using System;
using System.CodeDom;
using System.Collections.Generic;
using System.Collections.Immutable;
using System.Text.Json;
using System.Text.RegularExpressions;

namespace PSBicep.Core;

public partial class BicepWrapper
{
    public string? ConvertResourceToBicep(string resourceId, string resourceBody, bool includeTargetScope = false)
    {
        var id = AzureHelpers.ValidateResourceId(resourceId);
        var matchedType = BicepHelper.ResolveBicepTypeDefinition(id.FullyQualifiedType, azResourceTypeLoader, logger);
        JsonElement resource = JsonSerializer.Deserialize<JsonElement>(resourceBody);

        return AzureResourceProvider.GenerateBicepTemplate(id, matchedType, resource, includeTargetScope);
    }
}
