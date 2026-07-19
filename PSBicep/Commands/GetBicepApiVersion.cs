using System.Management.Automation;

namespace PSBicep.Commands;

[Cmdlet(VerbsCommon.Get, "BicepApiVersion")]
[CmdletBinding()]
[OutputType(typeof(string))]
public class GetBicepApiVersion : BaseCommand
{
    [ArgumentCompleter(typeof(Completers.BicepTypeCompleterWithoutApiVersions))]
    [Parameter(Mandatory = true, ValueFromPipeline = true)]
    [ValidateNotNullOrEmpty]
    public string ResourceType { get; set; }

    [Parameter(Mandatory = false, ValueFromPipeline = false)]
    public int Skip { get; set; } = 0;

    [Parameter(Mandatory = false, ValueFromPipeline = false)]

    public SwitchParameter AvoidPreview { get; set; }

    protected override void ProcessRecord()
    {
        WriteObject(psBicep.coreService.GetApiVersions(ResourceType, Skip, AvoidPreview.IsPresent), true);
    }
}
