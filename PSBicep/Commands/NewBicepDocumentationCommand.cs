using System.Collections;
using System.Management.Automation;

namespace PSBicep.Commands;

[Cmdlet(VerbsCommon.New, "BicepDocumentation")]
public class NewBicepDocumentationCommand : BaseCommand
{
    [Parameter(Mandatory = true, ValueFromPipeline = true)]
    [ValidateNotNullOrEmpty]
    public string Path { get; set; }

    [Parameter()]
    [ValidateNotNullOrEmpty]
    public string TemplateFile { get; set; }

    [Parameter()]
    [ValidateNotNullOrEmpty]
    public string TemplateRoot { get; set; }

    [Parameter()]
    public Hashtable CustomValue { get; set; }

    [Parameter()]
    public SwitchParameter NoRestore { get; set; }

    protected override void ProcessRecord()
    {
        WriteObject(psBicep.coreService.GenerateDocumentation(
            Path,
            templateFile: TemplateFile,
            templateRoot: TemplateRoot,
            customValues: CustomValue,
            noRestore: NoRestore.IsPresent));
    }
}
