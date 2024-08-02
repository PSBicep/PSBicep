using System.Management.Automation;

namespace PSBicep.Commands;

[Cmdlet(VerbsLifecycle.Build, "BicepParamFile")]
public class BuildBicepParamFileCommand : BaseCommand
{
    [Parameter(Mandatory = true, ValueFromPipeline = true)]
    [ValidateNotNullOrEmpty]
    public string Path { get; set; }

    [Parameter(Mandatory = false)]
    [ValidateNotNullOrEmpty]
    public string TemplatePath { get; set; } = "";

    [Parameter()]
    public SwitchParameter NoRestore { get; set; }

    protected override void ProcessRecord()
    {
        var result = bicepWrapper.Build(Path, TemplatePath, NoRestore.IsPresent);
        foreach (var item in result)
        {
            WriteObject(item);
        }
    }
}