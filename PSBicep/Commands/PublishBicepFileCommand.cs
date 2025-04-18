using System.Management.Automation;

namespace PSBicep.Commands;

[Cmdlet(VerbsData.Publish, "BicepFile")]
public class PublishBicepFileCommand : BaseCommand
{
    [Parameter(Mandatory = true, ValueFromPipeline = true)]
    [ValidateNotNullOrEmpty]
    public string Path { get; set; }

    [Parameter(Mandatory = true)]
    [ValidateNotNullOrEmpty]
    public string Target { get; set; }

    [Parameter(Mandatory = true)]
    [ValidateNotNullOrEmpty]
    public string Token { get; set; }

    [Parameter(Mandatory = false)]
    [ValidateNotNullOrEmpty]
    public string DocumentationUri { get; set; }

    [Parameter(Mandatory = false)]
    public SwitchParameter PublishSource { get; set; }

    [Parameter(Mandatory = false)]
    public SwitchParameter Force { get; set; }
    protected override void ProcessRecord()
    {
        bicepService.publisher.Publish(Path, Target, Token, DocumentationUri, PublishSource.IsPresent, Force.IsPresent);
    }
}
