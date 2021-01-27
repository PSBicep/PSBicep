// 2020-08-01-1

param name string
param securityRules array = []
param tags object = {}
param location string = resourceGroup().location

resource nsg  'Microsoft.Network/networkSecurityGroups@2020-08-01' = {
    name: name
    location: location
    properties: {
        securityRules: securityRules
    }    
}

output id string = nsg.id