using PSBicep.Core;
using System.Management.Automation;

namespace PSBicep.Commands;

public class BaseCommand : PSCmdlet
{
    protected string name;
    protected BicepWrapper bicepWrapper;

    protected override void BeginProcessing()
    {
        base.BeginProcessing();
        bicepWrapper = new BicepWrapper(this);
    }
}
