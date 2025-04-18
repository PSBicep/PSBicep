using System.Management.Automation;
using PSBicep.Core;

namespace PSBicep.Commands;

public class BaseCommand : PSCmdlet
{
    protected string name;
    protected BicepService bicepService;

    protected override void BeginProcessing()
    {
        base.BeginProcessing();
        bicepService = new BicepService(this);
    }

    protected void SetAuthentication(string token)
    {
        bicepService.authentication.SetAuthentication(token);
    }
}
