using System.Management.Automation;

namespace PSBicep.Commands;

[Cmdlet(VerbsCommon.Clear, "BicepCredential")]
[CmdletBinding()]
public class ClearBicepCredentialCommand : BaseCommand
{
    protected override void BeginProcessing()
    {
        base.BeginProcessing();
        bicepWrapper.ClearAuthentication();
    }
}