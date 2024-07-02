using System;
using System.Management.Automation;

namespace BicepNet.PS.Commands;

[Cmdlet(VerbsCommon.Set, "BicepNetCredential")]
[CmdletBinding(DefaultParameterSetName = "Interactive")]
public class SetBicepNetCredentialCommand : BicepNetBaseCommand
{
    [Parameter(Mandatory = true, ParameterSetName = "Token")]
    [ValidateNotNullOrEmpty]
    public string AccessToken { get; set; }

    [Parameter(ParameterSetName = "Interactive")]
    [ValidateNotNullOrEmpty]
    public string TenantId { get; set; }

    protected override void BeginProcessing()
    {
        base.BeginProcessing();
        switch (ParameterSetName)
        {
            case "Token":
                bicepWrapper.SetAuthentication(AccessToken);
                break;
            case "Interactive":
                bicepWrapper.SetAuthentication(null, TenantId);
                break;
            default:
                throw new InvalidOperationException("Not a valid parameter set!");
        }
    }
}