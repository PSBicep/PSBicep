using System.Management.Automation;

namespace BicepNet.PS.Commands;

[Cmdlet(VerbsData.ConvertTo, "BicepNetFile")]
public class ConvertToBicepNetFile : BicepNetBaseCommand
{
    [Parameter(Mandatory = true, ValueFromPipeline = true)]
    [ValidateNotNullOrEmpty]
    public string Path { get; set; }

    protected override void ProcessRecord()
    {
        var result = bicepWrapper.Decompile(Path);
        WriteObject(result);
    }
}