using System.Management.Automation;

namespace PSBicep.Commands;

[Cmdlet(VerbsCommon.Get, "BicepCachePath", DefaultParameterSetName = "br")]
[CmdletBinding]
public class GetBicepCachePathCommand : BaseCommand
{
    [Parameter(ParameterSetName="br")]
    public SwitchParameter Oci { get; set; }

    [Parameter(Mandatory = true, ParameterSetName = "ts")]
    public SwitchParameter TemplateSpecs { get; set; }

    protected override void EndProcessing()
    {
        string result = "";
        if (Oci.IsPresent || ParameterSetName == "br")
        {
            result = bicepWrapper.OciCachePath;
        }
        else if (TemplateSpecs.IsPresent)
        {
            result = bicepWrapper.TemplateSpecsCachePath;
        }
        WriteObject(result);
    }
}