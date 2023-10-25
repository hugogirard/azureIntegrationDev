param location string
@secure()
param adminUsername string
@secure()
param adminPassword string
param subnetId string

resource pip 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: 'pip-box'
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource myNic 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: 'myNic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig'
        properties: {
          subnet: {
            id: subnetId
          }
          publicIPAddress: {
            id: pip.id
          }
        }
      }
    ]
  }
}

resource myVm 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: 'dev'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v4'
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter'
        version: 'latest'
      }
      osDisk: {
        name: 'dev-osdisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
        diskSizeGB: 128
      }
    }
    osProfile: {
      computerName: 'dev'
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: myNic.id
        }
      ]
    }
  }
}
