using System.Management.Automation;

namespace BicepNet.PS.Commands;

[Cmdlet(VerbsData.Export, "BicepNetChildResource")]
public class ExportBicepNetChildResourceCommand : BicepNetBaseCommand
{
    [Parameter(Mandatory = true, ValueFromPipeline = true)]
    [ValidateNotNullOrEmpty]
    public string ParentResourceId { get; set; }

    [Parameter(Mandatory = false)]
    public SwitchParameter IncludeTargetScope { get; set; }

    protected override void ProcessRecord()
    {
        var result = bicepWrapper.ExportChildResoures(ParentResourceId, includeTargetScope: IncludeTargetScope.IsPresent);
        WriteObject(result);
    }
}
