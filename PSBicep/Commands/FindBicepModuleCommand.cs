using System;
using System.Management.Automation;

namespace PSBicep.Commands;

[Cmdlet(VerbsCommon.Find, "BicepModule")]
public class FindBicepModuleCommand : BaseCommand
{
    [Parameter(ValueFromPipeline = true, ValueFromPipelineByPropertyName = true, ParameterSetName = "Path")]
    [ValidateNotNullOrEmpty]
    public string BicepPath { get; set; }

    [Parameter(ValueFromPipeline = true, ValueFromPipelineByPropertyName = true, ParameterSetName = "Registry")]
    [ValidateNotNullOrEmpty]
    public string Registry { get; set; }

    [Parameter(ValueFromPipelineByPropertyName = true, ParameterSetName = "Registry")]
    [ValidateNotNullOrEmpty]
    public string ConfigurationPath { get; set; }

    [Parameter(ParameterSetName = "Cache")]
    public SwitchParameter Cache { get; set; }

    protected override void ProcessRecord()
    {
        var result = ParameterSetName switch
        {
            "Path" => bicepWrapper.FindModules(BicepPath, false, BicepPath),
            "Registry" => bicepWrapper.FindModules(Registry, true, ConfigurationPath),
            "Cache" => bicepWrapper.FindModules(),
            _ => throw new InvalidOperationException("Invalid parameter set"),
        };

        foreach (var item in result)
        {
            WriteObject(item);
        }
    }
}