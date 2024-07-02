using System;
using System.Management.Automation;

namespace BicepNet.PS.Commands;

[Cmdlet(VerbsCommon.Find, "BicepNetModule")]
public class FindBicepNetModuleCommand : BicepNetBaseCommand
{
    [Parameter(ValueFromPipeline = true, ValueFromPipelineByPropertyName = true, ParameterSetName = "Path")]
    [ValidateNotNullOrEmpty]
    public string Path { get; set; }

    [Parameter(ValueFromPipeline = true, ValueFromPipelineByPropertyName = true, ParameterSetName = "Registry")]
    [ValidateNotNullOrEmpty]
    public string Registry { get; set; }

    [Parameter(ParameterSetName = "Cache")]
    public SwitchParameter Cache { get; set; }

    protected override void ProcessRecord()
    {
        var result = ParameterSetName switch {
            "Path" => bicepWrapper.FindModules(Path, false),
            "Registry" => bicepWrapper.FindModules(Registry, true),
            "Cache" => bicepWrapper.FindModules(),
            _ => throw new InvalidOperationException("Invalid parameter set"),
        };

        foreach (var item in result)
        {
            WriteObject(item);
        }
    }
}