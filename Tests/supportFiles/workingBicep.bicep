param location string = resourceGroup().location
param name string

var nameVariable = '${name}storageaccount'

resource storageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: nameVariable
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Premium_LRS'
  }
}

output resourceId string = storageaccount.id
