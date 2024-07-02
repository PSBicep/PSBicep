using System.Management.Automation;

namespace BicepNet.PS.Commands;

[Cmdlet(VerbsCommon.Get, "BicepNetVersion")]
[CmdletBinding]
public class GetBicepNetVersionCommand : BicepNetBaseCommand
{
    protected override void EndProcessing()
    {
        var result = bicepWrapper.BicepVersion;
        WriteObject(result);
    }
}