using System;
using System.Management.Automation;

namespace PSBicep.Commands;

[Cmdlet(VerbsCommon.Get, "BicepChildResourceType", DefaultParameterSetName = "byName")]
[CmdletBinding()]
[OutputType(typeof(string))]
public class GetBicepChildResourceType : BaseCommand
{
    [ArgumentCompleter(typeof(Completers.BicepResourceProviderCompleter))]
    [Parameter(Mandatory = false, Position = 0, ParameterSetName = "byName", HelpMessage = "The name of the resource provider to retrieve resource types for.")]
    public string ResourceProvider { get; set; } = string.Empty;

    [ArgumentCompleter(typeof(Completers.BicepResourceCompleter))]
    [Parameter(Mandatory = false, Position = 1, ParameterSetName = "byName", HelpMessage = "The name of the resource type to retrieve.")]
    public string Resource { get; set; } = string.Empty;

    [ArgumentCompleter(typeof(Completers.BicepResourceChildCompleter))]
    [Parameter(Mandatory = false, Position = 2, ParameterSetName = "byName", HelpMessage = "The name of the child resource type to retrieve.")]
    public string Child { get; set; } = string.Empty;

    [ArgumentCompleter(typeof(Completers.BicepTypeCompleter))]
    [Parameter(ParameterSetName = "byFullyQualifiedName", HelpMessage = "The fully qualified name of the child resource type to retrieve.")]
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
            if (typeParts.Length > 2)
            {
                Child = string.Join('/', typeParts[2..]);
            }
        }
        WriteObject(psBicep.coreService.GetChildResourceTypeNames(ResourceProvider, Resource, Child, OutputFullyQualifiedName.IsPresent, ExactMatch.IsPresent), true);
    }
}
