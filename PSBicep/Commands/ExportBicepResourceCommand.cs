﻿using System.Management.Automation;

namespace PSBicep.Commands;

[Cmdlet(VerbsData.Export, "BicepResource")]
public class ExportBicepResourceCommand : BaseCommand
{
    [Parameter(Mandatory = true, ValueFromPipeline = true)]
    [ValidateNotNullOrEmpty]
    public string[] ResourceId { get; set; }

    [Parameter(Mandatory = false, ValueFromPipeline = false)]
    public SwitchParameter IncludeTargetScope { get; set; }

    protected override void ProcessRecord()
    {
        try
        {
            var result = bicepWrapper.ExportResources(ResourceId, MyInvocation.PSCommandPath, IncludeTargetScope.IsPresent);
            WriteObject(result);
        }
        catch (System.Exception exception)
        {
            WriteError(new ErrorRecord(exception, this.name, ErrorCategory.WriteError, null));
            throw;
        }
    }
}
