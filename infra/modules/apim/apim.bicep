param suffix string
param location string
@secure()
param publisherEmail string
@secure()
param publisherName string

resource apim 'Microsoft.ApiManagement/service@2023-03-01-preview' = {
  name: 'apim-${suffix}'
  location: location
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
  }
  sku: {
    name: 'Consumption'
    capacity: 0
  }
}
