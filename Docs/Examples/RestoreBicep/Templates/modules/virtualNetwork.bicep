// 2020-08-01-1

param vnetName string
param addressPrefixes array = [
  '10.0.0.0/16'
]
param subnets array
param dnsServers array = []
param enableDdosProtection bool = false
param ddosProtectionPlanId string = ''
param tags object = {}
param location string = resourceGroup().location

resource vnet 'Microsoft.Network/virtualNetworks@2020-08-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
    dhcpOptions: {
      dnsServers: dnsServers
    }
    enableDdosProtection: enableDdosProtection
    ddosProtectionPlan: enableDdosProtection ? {
      id: ddosProtectionPlanId
    } : json('null')
    subnets: subnets
  }
}

output id string = vnet.id