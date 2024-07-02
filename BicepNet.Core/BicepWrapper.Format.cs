using Bicep.Core.Parsing;
using Bicep.Core.PrettyPrint;
using Bicep.Core.PrettyPrint.Options;
using Bicep.Core.Workspaces;
using System;

namespace BicepNet.Core;

public partial class BicepWrapper
{
    public static string Format(string content,  string kind, string newline, string indentKind, int indentSize = 2, bool insertFinalNewline = false)
    {
        var fileKind = (BicepSourceFileKind)Enum.Parse(typeof(BicepSourceFileKind), kind, true);
        var newlineOption = (NewlineOption)Enum.Parse(typeof(NewlineOption), newline, true);
        var indentKindOption = (IndentKindOption)Enum.Parse(typeof(IndentKindOption), indentKind, true);

        BaseParser parser = fileKind == BicepSourceFileKind.BicepFile ? new Parser(content) : new ParamsParser(content);

        var options = new PrettyPrintOptions(newlineOption, indentKindOption, indentSize, insertFinalNewline);
        var output = PrettyPrinter.PrintProgram(parser.Program(), options, parser.LexingErrorLookup, parser.ParsingErrorLookup);
        
        return output;
    }
}
