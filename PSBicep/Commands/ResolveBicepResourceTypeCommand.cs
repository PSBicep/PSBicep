using System.Management.Automation;

namespace PSBicep.Commands;

[Cmdlet(VerbsDiagnostic.Resolve, "BicepResourceType")]
[CmdletBinding()]
public class ResolveBicepResourceTypeCommand : BaseCommand
{
    [Parameter(Mandatory = true, ValueFromPipeline = true)]
    [ValidateNotNullOrEmpty]
    public string ResourceId { get; set; }

    protected override void BeginProcessing()
    {
        base.BeginProcessing();
        WriteObject(bicepWrapper.ResolveBicepResourceType(ResourceId));
    }
}