using System.Management.Automation;

namespace BicepNet.PS.Commands;

[Cmdlet(VerbsData.Restore, "BicepNetFile")]
public class RestoreBicepNetFileCommand : BicepNetBaseCommand
{
    [Parameter(Mandatory = true, ValueFromPipeline = true)]
    [ValidateNotNullOrEmpty]
    public string Path { get; set; }

    protected override void ProcessRecord()
    {
        bicepWrapper.Restore(Path);
    }
}