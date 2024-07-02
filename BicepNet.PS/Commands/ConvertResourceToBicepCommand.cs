using System.Management.Automation;

namespace BicepNet.PS.Commands;

[Cmdlet(VerbsData.Convert, "BicepNetResourceToBicep")]
public class ConvertBicepNetResourceToBicep : BicepNetBaseCommand
{
    [Parameter(Mandatory = true)]
    [ValidateNotNullOrEmpty]
    public string ResourceId { get; set; }

    [Parameter(Mandatory = true)]
    [ValidateNotNullOrEmpty]
    public string ResourceBody { get; set; }

    protected override void ProcessRecord()
    {
        var result = bicepWrapper.ConvertResourceToBicep(ResourceId, ResourceBody);
        WriteObject(result);
    }
}