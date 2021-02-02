param (
    $ResourceGroup,
    $TemplateFilePath,
    $ParameterFilePath,
    $SubnetPathFilter = '.\subnets\*Subnets*.json'
)

# Read all subnet-parmeterfiles, merge into one array and escape the json
$subnets = Get-ChildItem -Path $SubnetPathFilter | 
    Foreach-Object -Process {
        Get-Content -Path $_.Fullname | 
        ConvertFrom-Json -AsHashtable
    } | 
    ConvertTo-Json -AsArray -Depth 100 -Compress | 
    ConvertTo-Json

# Deploy template with parameter file, override subnet-parameter.
az deployment group create -g $ResourceGroup -f $TemplateFilePath -p $ParameterFilePath -p "subnets=$subnets"