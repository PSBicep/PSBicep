using System.Linq;
using System.Management.Automation;
using PSBicep.Core.Configuration;

namespace PSBicep.Commands;

[Cmdlet(VerbsCommon.Get, "BicepConfig", DefaultParameterSetName = "Default")]
[CmdletBinding()]
public class GetBicepConfigCommand : BaseCommand
{
    [Parameter(Mandatory = true, ParameterSetName = "PathLocal")]
    [Parameter(Mandatory = true, ParameterSetName = "PathMerged")]
    [Parameter(Mandatory = true, ParameterSetName = "PathOnly")]
    [ValidateNotNullOrEmpty()]
    [ValidateFileExists()]
    public string Path { get; set; }

    [Parameter(Mandatory = true, ParameterSetName = "PathLocal")]
    public SwitchParameter Local { get; set; }

    [Parameter(Mandatory = true, ParameterSetName = "PathMerged")]
    public SwitchParameter Merged { get; set; }

    [Parameter(ParameterSetName = "Default")]
    public SwitchParameter Default { get; set; }

    [Parameter(ParameterSetName = "Default")]
    [Parameter(ParameterSetName = "PathLocal")]
    [Parameter(ParameterSetName = "PathMerged")]
    [Parameter(ParameterSetName = "PathOnly")]
    public SwitchParameter AsString { get; set; }

    protected override void BeginProcessing()
    {
        base.BeginProcessing();
    }

    protected override void ProcessRecord()
    {
        string bicepFilePath = null;
        if (ParameterSetName != "Default")
        {
            bicepFilePath = SessionState.Path.GetResolvedPSPathFromPSPath(Path).FirstOrDefault().ToString();
        }
        BicepConfigScope scope = ParameterSetName switch
        {
            "PathLocal" => BicepConfigScope.Local,
            "PathMerged" => BicepConfigScope.Merged,
            "PathOnly" => BicepConfigScope.Merged,
            _ => BicepConfigScope.Default
        };
        var config = bicepWrapper.GetBicepConfigInfo(scope, bicepFilePath);
        if (AsString.IsPresent)
        {
            WriteObject(config.ToString());
        }
        else
        {
            WriteObject(config);
        }
    }
}

class ValidateFileExists : ValidateArgumentsAttribute
{
    protected override void Validate(object arguments, EngineIntrinsics engineIntrinsics)
    {
        var path = (string)arguments;
        if (!System.IO.Path.Exists(path))
        {
            throw new ValidationMetadataException($"File {path} does not exist");
        }
    }
}