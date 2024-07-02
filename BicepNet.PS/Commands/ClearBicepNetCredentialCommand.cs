using System.Management.Automation;

namespace BicepNet.PS.Commands;

[Cmdlet(VerbsCommon.Clear, "BicepNetCredential")]
[CmdletBinding()]
public class ClearBicepNetCredentialCommand : BicepNetBaseCommand
{
    protected override void BeginProcessing()
    {
        base.BeginProcessing();
        bicepWrapper.ClearAuthentication();
    }
}