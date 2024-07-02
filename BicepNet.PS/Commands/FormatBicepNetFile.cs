using System.Management.Automation;
using BicepNet.Core;

namespace BicepNet.PS.Commands;

[Cmdlet(VerbsCommon.Format, "BicepNet")]
public class FormatBicepNet : BicepNetBaseCommand
{
    [Parameter(Mandatory = true, ValueFromPipeline = true)]
    [ValidateNotNullOrEmpty]
    public string Content { get; set; }

    [Parameter(Mandatory = false, ValueFromPipeline = false)]
    [ValidateNotNullOrEmpty]
    [ValidateSet("BicepFile", "ParamsFile")]
    public string FileKind { get; set; } = "BicepFile";

    [Parameter(Mandatory = false, ValueFromPipeline = false)]
    [ValidateNotNullOrEmpty]
    [ValidateSet("Auto", "LF", "CRLF")]
    public string NewlineOption { get; set; } = "Auto";

    [Parameter(Mandatory = false, ValueFromPipeline = false)]
    [ValidateNotNullOrEmpty]
    [ValidateSet("Space", "Tab")]
    public string IndentKindOption { get; set; } = "Space";

    [Parameter(Mandatory = false, ValueFromPipeline = false)]
    [ValidateNotNullOrEmpty]
    public int IndentSize { get; set; } = 2;

    [Parameter(Mandatory = false, ValueFromPipeline = false)]
    [ValidateNotNullOrEmpty]
    public bool InsertFinalNewline { get; set; } = false;

    protected override void ProcessRecord()
    {
        var result = BicepWrapper.Format(Content, FileKind, NewlineOption, IndentKindOption, IndentSize, InsertFinalNewline);
        WriteObject(result);
    }
}