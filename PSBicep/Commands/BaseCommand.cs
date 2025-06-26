using System.Management.Automation;
using PSBicep.LoadContext;

namespace PSBicep.Commands;

public class BaseCommand : PSCmdlet
{
    protected string name;
    protected Core.PSBicep psBicep;

    protected override void BeginProcessing()
    {
        base.BeginProcessing();
        psBicep = BicepLoader.PSBicep;
        psBicep.coreService.InitializeLogger(this);
    }

    protected override void EndProcessing()
    {
        base.EndProcessing();
        psBicep.coreService.UnloadLogger();
    }

    protected void SetAuthentication(string token)
    {
        psBicep.registryService.SetAuthentication(token);
    }
}
