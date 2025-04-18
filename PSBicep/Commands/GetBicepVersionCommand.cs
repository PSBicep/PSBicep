using System.Management.Automation;
using PSBicep.Core;

namespace PSBicep.Commands;

[Cmdlet(VerbsCommon.Get, "BicepVersion")]
[CmdletBinding]
public class GetBicepVersionCommand : BaseCommand
{
    protected override void EndProcessing()
    {
        var result = BicepService.BicepVersion;
        WriteObject(result);
    }
}