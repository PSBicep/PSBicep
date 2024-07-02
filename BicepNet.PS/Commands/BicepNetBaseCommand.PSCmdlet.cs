using BicepNet.Core;
using System.Management.Automation;

namespace BicepNet.PS.Commands;

public partial class BicepNetBaseCommand : PSCmdlet
{
    protected string name;
    protected BicepWrapper bicepWrapper;

    protected override void BeginProcessing()
    {
        base.BeginProcessing();
        bicepWrapper = new BicepWrapper(this);
        name = MyInvocation.InvocationName;
    }
}
