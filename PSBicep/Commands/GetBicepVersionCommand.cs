using System.Management.Automation;

namespace PSBicep.Commands;

[Cmdlet(VerbsCommon.Get, "BicepVersion")]
[CmdletBinding]
public class GetBicepVersionCommand : BaseCommand
{
    protected override void EndProcessing()
    {
        var result = bicepService.bicepVersion;
        WriteObject(result);
    }
}