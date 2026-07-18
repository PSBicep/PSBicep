using System;
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
    [Parameter(ParameterSetName = "byFullyQualifiedName")]
    public SwitchParameter ExactMatch { get; set; }

    [ArgumentCompleter(typeof(Completers.BicepTypeCompleter))]
    [Parameter(ParameterSetName = "byFullyQualifiedName", HelpMessage = "The resource provider namespace to retrieve.")]
    public string FullyQualifiedName { get; set; } = string.Empty;

    protected override void ProcessRecord()
    {
        if (ParameterSetName == "byFullyQualifiedName")
        {
            var typeParts = FullyQualifiedName.Split('/');
            switch (typeParts.Length)
            {
                case 1:
                    ResourceProvider = typeParts[0];
                    break;
                default:
                    ThrowTerminatingError(new ErrorRecord(
                        new ArgumentException($"Invalid fully qualified name '{FullyQualifiedName}'. Expected format: 'provider'."),
                        "InvalidFullyQualifiedName",
                        ErrorCategory.InvalidArgument,
                        FullyQualifiedName));
                    break;
            }
        }
        WriteObject(psBicep.coreService.GetResourceProviderNames(ResourceProvider, false, ExactMatch.IsPresent), true);
    }
}
