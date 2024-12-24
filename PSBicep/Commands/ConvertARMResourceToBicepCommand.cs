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

    [Parameter()]
    public SwitchParameter IncludeTargetScope { get; set; }

    [Parameter()]
    public SwitchParameter RemoveUnknownProperties { get; set; }

    protected override void ProcessRecord()
    {
        var result = bicepWrapper.ConvertResourceToBicep(ResourceId, ResourceBody, ConfigurationPath, IncludeTargetScope.IsPresent, RemoveUnknownProperties.IsPresent);
        WriteObject(result);
    }
}