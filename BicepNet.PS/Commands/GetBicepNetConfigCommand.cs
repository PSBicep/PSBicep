using BicepNet.Core.Configuration;
using System;
using System.Management.Automation;

namespace BicepNet.PS.Commands;

[Cmdlet(VerbsCommon.Get, "BicepNetConfig")]
[CmdletBinding()]
public class GetBicepNetConfigCommand : BicepNetBaseCommand
{
    [Parameter(ParameterSetName = "Scope")]
    [ValidateSet(["Default", "Merged", "Local"])]
    public string Scope { get; set; }

    [Parameter(ValueFromPipeline = true)]
    [ValidateNotNullOrEmpty]
    public string Path { get; set; }

    protected override void BeginProcessing()
    {
        base.BeginProcessing();

        // If Scope is not set
        // Set Scope to Default if no Path, otherwise Merged
        Scope ??= Path is null ? "Default" : "Merged";

        if (Path is not null && Scope == "Default")
        {
            WriteWarning("The Path parameter is specified but the Scope parameter is set to Default, the Path will not be used!");
        }
    }

    protected override void ProcessRecord()
    {
        // Parse Scope to enum and pass it together to BicepWrapper with Path, which can be null here if not provided
        WriteObject(bicepWrapper.GetBicepConfigInfo((BicepConfigScope)Enum.Parse(typeof(BicepConfigScope), Scope), Path));
    }
}