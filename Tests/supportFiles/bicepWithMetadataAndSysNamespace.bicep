metadata test = 'test'

@sys.description('This is a test')
param location string = resourceGroup().location
param name string

metadata test2 = 'test'


resource storageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: name
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Premium_LRS'
  }
}

output resourceId string = storageaccount.id
