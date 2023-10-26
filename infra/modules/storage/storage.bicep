param location string
param suffix string

resource storage 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: 'strf${suffix}'
  location: location
  sku: {
    name: 'Standard_LRS'    
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    accessTier: 'Hot'
  }
}


output storageName string = storage.name
