param location string = resourceGroup().location
param name string

resource storageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: name
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Premium_LRS'
    tier: 'Premium'
  }
}

output resourceId string = storageaccount.id
