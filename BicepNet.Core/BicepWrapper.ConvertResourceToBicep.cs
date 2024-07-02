using Bicep.Core.PrettyPrint;
using Bicep.Core.PrettyPrint.Options;
using Bicep.Core.Rewriters;
using Bicep.Core.Semantics;
using Bicep.Core.Workspaces;
using BicepNet.Core.Azure;
using System;
using System.Collections.Immutable;
using System.Text.Json;

namespace BicepNet.Core;

public partial class BicepWrapper
{
    public string ConvertResourceToBicep(string resourceId, string resourceBody)
    {
        var id = AzureHelpers.ValidateResourceId(resourceId);
        var matchedType = BicepHelper.ResolveBicepTypeDefinition(id.FullyQualifiedType, azResourceTypeLoader, logger);
        JsonElement resource = JsonSerializer.Deserialize<JsonElement>(resourceBody);

        var template = AzureResourceProvider.GenerateBicepTemplate(id, matchedType, resource, includeTargetScope: true);
        return RewriteBicepTemplate(template);
    }

    public string RewriteBicepTemplate(string template)
    {
        BicepFile virtualBicepFile = SourceFileFactory.CreateBicepFile(new Uri($"inmemory:///generated.bicep"), template);

        var sourceFileGrouping = SourceFileGroupingBuilder.Build(
            fileResolver,
            moduleDispatcher,
            configurationManager,
            workspace,
            virtualBicepFile.FileUri,
            featureProviderFactory,
            false);
 
        var compilation = new Compilation(
            featureProviderFactory,
            environment,
            namespaceProvider,
            sourceFileGrouping,
            configurationManager,
            bicepAnalyzer,
            moduleDispatcher,
            new AuxiliaryFileCache(fileResolver),
            ImmutableDictionary<ISourceFile, ISemanticModel>.Empty);

        var bicepFile = RewriterHelper.RewriteMultiple(
            compiler,
            compilation,
            virtualBicepFile,
            rewritePasses: 1,
            model => new TypeCasingFixerRewriter(model),
            model => new ReadOnlyPropertyRemovalRewriter(model));

        var printOptions = new PrettyPrintOptions(NewlineOption.LF, IndentKindOption.Space, 2, false);
        template = PrettyPrinter.PrintValidProgram(bicepFile.ProgramSyntax, printOptions);

        return template;
    }
}
