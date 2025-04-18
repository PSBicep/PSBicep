using System.Management.Automation;

namespace PSBicep.Commands;

[Cmdlet(VerbsData.Restore, "BicepFile")]
public class RestoreBicepFileCommand : BaseCommand
{
    [Parameter(Mandatory = true, ValueFromPipeline = true)]
    [ValidateNotNullOrEmpty]
    public string Path { get; set; }

    [Parameter(Mandatory = true, ValueFromPipeline = true)]
    [ValidateNotNullOrEmpty]
    public SwitchParameter Force { get; set; }

    [Parameter(Mandatory = false, ValueFromPipeline = false)]
    [ValidateNotNullOrEmpty]
    public string Token { get; set; }

    protected override void BeginProcessing()
    {
        base.BeginProcessing();
        if (!string.IsNullOrEmpty(Token))
        {
            SetAuthentication(Token);
        }
    }
    protected override void ProcessRecord()
    {
        bicepService.restorer.Restore(Path, Force.IsPresent);
    }
}