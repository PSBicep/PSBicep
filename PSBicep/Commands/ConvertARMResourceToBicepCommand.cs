using System.Management.Automation;

namespace PSBicep.Commands;

[Cmdlet(VerbsData.Convert, "ARMResourceToBicep")]
public class ConvertARMResourceToBicep : BaseCommand
{
    [Parameter(Mandatory = true)]
    [ValidateNotNullOrEmpty]
    public string ResourceId { get; set; }

    [Parameter(Mandatory = true)]
    [ValidateNotNullOrEmpty]
    public string ResourceBody { get; set; }

    [Parameter()]
    public string ConfigurationPath { get; set; }

    protected override void ProcessRecord()
    {
        var result = bicepWrapper.ConvertResourceToBicep(ResourceId, ResourceBody, ConfigurationPath);
        WriteObject(result);
    }
}