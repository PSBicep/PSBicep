using System;
using System.Management.Automation;

namespace PSBicep.Commands;

[Cmdlet(VerbsCommon.Get, "BicepResourceType", DefaultParameterSetName = "byName")]
[CmdletBinding()]
[OutputType(typeof(string))]
public class GetBicepResourceType : BaseCommand
{
    [ArgumentCompleter(typeof(Completers.BicepResourceProviderCompleter))]
    [Parameter(Mandatory = false, Position = 0, ParameterSetName = "byName", HelpMessage = "The name of the resource provider to retrieve resource types for.")]
    public string ResourceProvider { get; set; } = string.Empty;

    [ArgumentCompleter(typeof(Completers.BicepResourceCompleter))]
    [Parameter(Mandatory = false, Position = 1, ParameterSetName = "byName", HelpMessage = "The name of the resource type to retrieve.")]
    public string Resource { get; set; } = string.Empty;

    [ArgumentCompleter(typeof(Completers.BicepTypeCompleter))]
    [Parameter(ParameterSetName = "byFullyQualifiedName", HelpMessage = "The fully qualified resource type to retrieve.")]
    public string FullyQualifiedName { get; set; } = string.Empty;

    [Parameter(ParameterSetName = "byName")]
    [Parameter(ParameterSetName = "byFullyQualifiedName")]
    public SwitchParameter OutputFullyQualifiedName { get; set; }

    [Parameter(ParameterSetName = "byName")]
    [Parameter(ParameterSetName = "byFullyQualifiedName")]
    public SwitchParameter ExactMatch { get; set; }

    protected override void ProcessRecord()
    {
        if (ParameterSetName == "byFullyQualifiedName")
        {
            var typeParts = FullyQualifiedName.Split('/');
            ResourceProvider = typeParts[0];
            if (typeParts.Length > 1)
            {
                Resource = typeParts[1];
            }
        }

        WriteObject(psBicep.coreService.GetResourceTypeNames(ResourceProvider, Resource, OutputFullyQualifiedName.IsPresent, ExactMatch.IsPresent), true);
    }
}
