using System;
using System.IO;
using Bicep.Core.FileSystem;
using Bicep.Core.PrettyPrintV2;
using Bicep.Core.SourceGraph;

namespace PSBicep.Core;

public partial class BicepWrapper
{
    public string Format(string content, string kind, string newline, string indentKind, int indentSize = 2, int width = 120, bool insertFinalNewline = false)
    {
        var fileKind = (BicepSourceFileKind)Enum.Parse(typeof(BicepSourceFileKind), kind, true);
        var newlineOption = (NewlineKind)Enum.Parse(typeof(NewlineKind), newline, true);
        var indentKindOption = (IndentKind)Enum.Parse(typeof(IndentKind), indentKind, true);

        var options = new PrettyPrinterV2Options(indentKindOption, newlineOption, indentSize, width, insertFinalNewline);

        return Format(content, options, fileKind);
    }

    public string Format(string content, string configurationPath, string kind = "BicepFile")
    {
        var configuration = configurationManager.GetConfiguration(PathHelper.FilePathToFileUrl(configurationPath ?? ""));
        var fileKind = (BicepSourceFileKind)Enum.Parse(typeof(BicepSourceFileKind), kind, true);
        return Format(content, configuration.Formatting.Data, fileKind);
    }

    public string Format(string content, PrettyPrinterV2Options options, BicepSourceFileKind fileKind = BicepSourceFileKind.BicepFile)
    {
        var uri = fileKind == BicepSourceFileKind.BicepFile ? new Uri("inmemory:///generated.bicep") : new Uri("inmemory:///generated.bicepparams");
        if (compiler.SourceFileFactory.CreateSourceFile(uri, content) is not BicepSourceFile sourceFile)
        {
            throw new InvalidOperationException("Unable to create Bicep source file.");
        }

        var context = PrettyPrinterV2Context.Create(options, sourceFile.LexingErrorLookup, sourceFile.ParsingErrorLookup);

        using var stringWriter = new StringWriter();
        PrettyPrinterV2.PrintTo(stringWriter, sourceFile.ProgramSyntax, context);
        return stringWriter.ToString();
    }
}
