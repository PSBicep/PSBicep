using System.Collections;
using System.Management.Automation;

namespace PSBicep.Commands;

[Cmdlet(VerbsData.Convert, "ARMResourceToBicep")]
public class ConvertARMResourceToBicep : BaseCommand
{
    [Parameter(Mandatory = true, ParameterSetName = "ResourceId")]
    [ValidateNotNullOrEmpty]
    public string ResourceId { get; set; }

    [Parameter(Mandatory = true, ParameterSetName = "ResourceId")]
    [ValidateNotNullOrEmpty]
    public string ResourceBody { get; set; }

    [Parameter(Mandatory = true, ParameterSetName = "ResourceDictionary")]
    public Hashtable ResourceDictionary { get; set; }

    [Parameter(ParameterSetName = "ResourceId")]
    [Parameter(ParameterSetName = "ResourceDictionary")]
    public string ConfigurationPath { get; set; }

    [Parameter(ParameterSetName = "ResourceId")]
    [Parameter(ParameterSetName = "ResourceDictionary")]
    public SwitchParameter IncludeTargetScope { get; set; }

    [Parameter(ParameterSetName = "ResourceId")]
    [Parameter(ParameterSetName = "ResourceDictionary")]
    public SwitchParameter RemoveUnknownProperties { get; set; }

    protected override void ProcessRecord()
    {
        switch (ParameterSetName)
        {
            case "ResourceId":
                var result = bicepWrapper.ConvertResourceToBicep(ResourceId, ResourceBody, ConfigurationPath, IncludeTargetScope.IsPresent, RemoveUnknownProperties.IsPresent);
                WriteObject(result.Item2);
                break;
            case "ResourceDictionary":
                var dictResult = bicepWrapper.ConvertResourceToBicep(ResourceDictionary, ConfigurationPath, IncludeTargetScope.IsPresent, RemoveUnknownProperties.IsPresent);
                WriteObject(dictResult);
                break;
            default:
                throw new PSInvalidOperationException("Invalid parameter set");
        }
    }
}