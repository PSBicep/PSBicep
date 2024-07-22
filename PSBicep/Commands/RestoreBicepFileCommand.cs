using System.Management.Automation;

namespace PSBicep.Commands;

[Cmdlet(VerbsData.Restore, "BicepFile")]
public class RestoreBicepFileCommand : BaseCommand
{
    [Parameter(Mandatory = true, ValueFromPipeline = true)]
    [ValidateNotNullOrEmpty]
    public string Path { get; set; }

    protected override void ProcessRecord()
    {
        bicepWrapper.Restore(Path);
    }
}