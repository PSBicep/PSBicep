using System.Management.Automation;

namespace PSBicep.Commands;

public class BaseCommand : PSCmdlet
{
    protected string name;
    protected Core.PSBicep psBicep;

    protected override void BeginProcessing()
    {
        base.BeginProcessing();
        psBicep = new Core.PSBicep(this);
    }

    protected void SetAuthentication(string token)
    {
        psBicep.registryService.SetAuthentication(token);
    }
}
