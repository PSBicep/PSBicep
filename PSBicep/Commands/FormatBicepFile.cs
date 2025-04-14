using System.Management.Automation;

namespace PSBicep.Commands;

[Cmdlet(VerbsCommon.Format, "Bicep")]
public class FormatBicep : BaseCommand
{
    [Parameter(Mandatory = true, ValueFromPipeline = true, ParameterSetName = "CustomConfig")]
    [Parameter(Mandatory = true, ValueFromPipeline = true, ParameterSetName = "BicepConfig")]
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
    public int Width { get; set; } = 120;

    [Parameter(Mandatory = false, ValueFromPipeline = false)]
    [ValidateNotNullOrEmpty]
    public bool InsertFinalNewline { get; set; } = false;

    protected override void ProcessRecord()
    {
        var result = bicepWrapper.Format(Content, FileKind, NewlineOption, IndentKindOption, IndentSize, Width, InsertFinalNewline);
        WriteObject(result);
    }
}