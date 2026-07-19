using System.Management.Automation;

namespace PSBicep.Commands;

[Cmdlet(VerbsCommon.Get, "BicepResourceProvider", DefaultParameterSetName = "byName")]
[CmdletBinding()]
[OutputType(typeof(string))]
public class GetBicepResourceProvider : BaseCommand
{
    [ArgumentCompleter(typeof(Completers.BicepResourceProviderCompleter))]
    [Parameter(Mandatory = false, Position = 0, ParameterSetName = "byName", HelpMessage = "The resource provider namespace to retrieve.")]
    public string ResourceProvider { get; set; } = string.Empty;

    [Parameter(ParameterSetName = "byName")]
    public SwitchParameter ExactMatch { get; set; }

    protected override void ProcessRecord()
    {
        WriteObject(psBicep.coreService.GetResourceProviderNames(ResourceProvider, false, ExactMatch.IsPresent), true);
    }
}
