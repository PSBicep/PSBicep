using System.Management.Automation;

namespace BicepNet.PS.Commands;

[Cmdlet(VerbsLifecycle.Build, "BicepNetFile")]
public class BuildBicepNetFileCommand : BicepNetBaseCommand
{
    [Parameter(Mandatory = true, ValueFromPipeline = true)]
    [ValidateNotNullOrEmpty]
    public string Path { get; set; }

    [Parameter()]
    public SwitchParameter NoRestore { get; set; }

    protected override void ProcessRecord()
    {
        var result = bicepWrapper.Build(Path, noRestore: NoRestore.IsPresent);
        foreach (var item in result)
        {
            WriteObject(item);
        }
    }
}
