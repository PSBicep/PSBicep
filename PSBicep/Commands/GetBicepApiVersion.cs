using System.Management.Automation;

namespace PSBicep.Commands;

[Cmdlet(VerbsCommon.Get, "BicepApiVersion")]
[CmdletBinding()]
public class GetBicepApiVersion : BaseCommand
{
    [Parameter(Mandatory = true, ValueFromPipeline = true)]
    [ValidateNotNullOrEmpty]
    public string ResourceType { get; set; }

    [Parameter(Mandatory = false, ValueFromPipeline = false)]
    public int Skip { get; set; } = 0;

    [Parameter(Mandatory = false, ValueFromPipeline = false)]

    public SwitchParameter AvoidPreview { get; set; }

    protected override void BeginProcessing()
    {
        base.BeginProcessing();
        WriteObject(psBicep.coreService.GetApiVersions(ResourceType, Skip, AvoidPreview.IsPresent));
    }
}