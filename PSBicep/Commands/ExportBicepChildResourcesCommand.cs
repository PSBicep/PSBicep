using System.Management.Automation;

namespace PSBicep.Commands;

[Cmdlet(VerbsData.Export, "BicepChildResource")]
public class ExportBicepChildResourceCommand : BaseCommand
{
    [Parameter(Mandatory = true, ValueFromPipeline = true)]
    [ValidateNotNullOrEmpty]
    public string ParentResourceId { get; set; }

    [Parameter(Mandatory = false)]
    public SwitchParameter IncludeTargetScope { get; set; }

    protected override void ProcessRecord()
    {
        WriteWarning("This command is deprecated and will be removed in a future release. Use Export-BicepResource instead. Please file an Issue on GitHub if you have a use case that still requires this command.");
        var result = bicepWrapper.ExportChildResoures(ParentResourceId, includeTargetScope: IncludeTargetScope.IsPresent);
        WriteObject(result);
    }
}
