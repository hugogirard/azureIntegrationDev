param location string
param vnetConfiguration object


resource nsgDevMachine 'Microsoft.Network/networkSecurityGroups@2023-05-01'= {
  name: 'nsg-dev-vm'
  location: location
  properties: {
    securityRules: [
      
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: vnetConfiguration.name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetConfiguration.addressPrefix
      ]
    }
    subnets: [
      {
        name: 'snet-dev-vm'
        properties: {
          addressPrefix: vnetConfiguration.subnetdevPrefix
          networkSecurityGroup: {
            id: nsgDevMachine.id
          }
        }
      }
    ]
  }
}

output subnetId string = vnet.properties.subnets[0].id
