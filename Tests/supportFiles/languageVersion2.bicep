param name string?

param location string = resourceGroup().location

module storage 'workingBicep.bicep' = {
  name: empty(name) ? 'storageDeploy' : name!
  params: {
    name: 'storagename123'
    location: location
  }
}
