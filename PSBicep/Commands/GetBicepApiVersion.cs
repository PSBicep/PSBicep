using System.Management.Automation;

namespace PSBicep.Commands;

[Cmdlet(VerbsCommon.Get, "BicepApiVersion")]
[CmdletBinding()]
public class GetBicepApiVersion : BaseCommand
{
    [Parameter(Mandatory = true, ValueFromPipeline = true)]
    [ValidateNotNullOrEmpty]
    public string ResourceTypeReference { get; set; }

    protected override void BeginProcessing()
    {
        base.BeginProcessing();
        WriteObject(bicepWrapper.GetApiVersions(ResourceTypeReference));
    }
}