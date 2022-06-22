param location string = resourceGroup().location

module storage 'workingBicep.bicep' = {
  name: 'storageDeploy'
  params: {
    name: 'storagename123'
    location: location
  }
}
