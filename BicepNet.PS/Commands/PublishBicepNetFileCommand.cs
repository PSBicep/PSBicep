using System.Management.Automation;

namespace BicepNet.PS.Commands;

[Cmdlet(VerbsData.Publish, "BicepNetFile")]
public class PublishBicepNetFileCommand : BicepNetBaseCommand
{
    [Parameter(Mandatory = true, ValueFromPipeline = true)]
    [ValidateNotNullOrEmpty]
    public string Path { get; set; }

    [Parameter(Mandatory = true)]
    [ValidateNotNullOrEmpty]
    public string Target { get; set; }

    [Parameter(Mandatory = false)]
    [ValidateNotNullOrEmpty]
    public string DocumentationUri { get; set; }

    [Parameter(Mandatory = false)]
    public SwitchParameter PublishSource { get; set; }

    [Parameter(Mandatory = false)]
    public SwitchParameter Force { get; set; }
    protected override void ProcessRecord()
    {
        bicepWrapper.Publish(Path, Target, DocumentationUri, PublishSource.IsPresent, Force.IsPresent);
    }
}
