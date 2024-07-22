using System.Management.Automation;

namespace PSBicep.Commands;

[Cmdlet(VerbsCommon.Get, "BicepAccessToken")]
[CmdletBinding()]
public class GetBicepAccessTokenCommand : BaseCommand
{
    protected override void BeginProcessing()
    {
        base.BeginProcessing();
        WriteObject(bicepWrapper.GetAccessToken());
    }
}