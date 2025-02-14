using System.Management.Automation;

namespace PSBicep.Commands;

[Cmdlet(VerbsData.Export, "BicepResource", DefaultParameterSetName = "AsString")]
public class ExportBicepResourceCommand : BaseCommand
{
    [Parameter(Mandatory = true, ValueFromPipeline = true, ValueFromPipelineByPropertyName = true, ParameterSetName = "Path")]
    [Parameter(Mandatory = true, ValueFromPipeline = true, ValueFromPipelineByPropertyName = true, ParameterSetName = "AsString")]
    [ValidateNotNullOrEmpty()]
    public string[] ResourceId { get; set; }

    [Parameter(Mandatory = false, ValueFromPipeline = false, ValueFromPipelineByPropertyName = false, ParameterSetName = "Path")]
    [Parameter(Mandatory = false, ValueFromPipeline = false, ValueFromPipelineByPropertyName = false, ParameterSetName = "AsString")]
    public SwitchParameter IncludeTargetScope { get; set; }

    [Parameter(Mandatory = true, ValueFromPipeline = false, ValueFromPipelineByPropertyName = true, ParameterSetName = "Path")]
    [Alias("PSPath", "Path")]
    [ValidateNotNullOrEmpty()]
    public string OutputDirectory { get; set; }

    protected override void BeginProcessing()
    {
        WriteWarning("This command is deprecated and will be removed in a future release. Use Export-BicepResource instead. Please file an Issue on GitHub if you have a use case that still requires this command.");
        base.BeginProcessing();
        if (ParameterSetName == "Path")
        {
            OutputDirectory = GetUnresolvedProviderPathFromPSPath(OutputDirectory);
            if (!System.IO.File.Exists(OutputDirectory))
            {
                System.IO.Directory.CreateDirectory(OutputDirectory);
            }
        }
    }

    protected override void ProcessRecord()
    {
        try
        {
            var result = bicepWrapper.ExportResources(ResourceId, OutputDirectory, IncludeTargetScope.IsPresent);
            if (ParameterSetName == "Path")
            {
                foreach (var (name, template) in result)
                {
                    var path = System.IO.Path.Combine(OutputDirectory, $"{name}.bicep");
                    System.IO.File.WriteAllText(path, template);
                }
            }
            else
            {
                WriteObject(result);
            }
        }
        catch (System.Exception exception)
        {
            WriteError(new ErrorRecord(exception, this.name, ErrorCategory.WriteError, null));
            throw;
        }
    }
}
