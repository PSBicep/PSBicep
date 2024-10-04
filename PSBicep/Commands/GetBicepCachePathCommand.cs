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

    [Parameter(Mandatory = false, ParameterSetName = "br")]
    [Parameter(Mandatory = false, ParameterSetName = "ts")]
    public string Path { get; set; } = "inmemory:///main.bicp";


    protected override void EndProcessing()
    {
        string result = "";
        if (Oci.IsPresent || ParameterSetName == "br")
        {
            result = bicepWrapper.GetOciCachePath(Path);
        }
        else if (TemplateSpecs.IsPresent)
        {
            result = bicepWrapper.GetTemplateSpecsCachePath(Path);
        }
        WriteObject(result);
    }
}