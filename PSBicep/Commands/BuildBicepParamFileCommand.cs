using System.Management.Automation;

namespace PSBicep.Commands;

[Cmdlet(VerbsLifecycle.Build, "BicepParamFile")]
public class BuildBicepParamFileCommand : BaseCommand
{
    [Parameter(Mandatory = true, ValueFromPipeline = true)]
    [ValidateNotNullOrEmpty]
    public string Path { get; set; }

    [Parameter()]
    public SwitchParameter NoRestore { get; set; }

    protected override void ProcessRecord()
    {
        var result = psBicep.coreService.Build(Path, NoRestore.IsPresent);
        WriteObject(result.Parameters);
    }
}