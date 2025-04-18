using System.Management.Automation;

namespace PSBicep.Commands;

[Cmdlet(VerbsData.ConvertTo, "BicepFile")]
public class ConvertToBicepFile : BaseCommand
{
    [Parameter(Mandatory = true, ValueFromPipeline = true)]
    [ValidateNotNullOrEmpty]
    public string Path { get; set; }

    protected override void ProcessRecord()
    {
        var result = bicepService.decompiler.Decompile(Path);
        WriteObject(result);
    }
}