
// 2020-08-01-1

param routeName string
param routes array = []
param disableBgpRoutePropagation bool = false
param tags object = {}
param location string = resourceGroup().location

resource route 'Microsoft.Network/routeTables@2020-07-01' = {
    name: routeName
    location: location
    tags: tags
    properties: {
        routes: routes
        disableBgpRoutePropagation: disableBgpRoutePropagation
    }
}

output id string = route.id