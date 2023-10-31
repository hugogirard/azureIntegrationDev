targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unqiue hash used in all resources.')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

@description('Configuration of the on-premises virtual network')
param vnetConfiguration object

@description('Name of the resource group to create')
param resourceGroupName string

@description('Password for the Windows VM')
@secure()
param adminPassword string

@description('Username for the Windows VM')
@secure()
param adminUsername string


var suffix = toLower(uniqueString(subscription().id, environmentName, location))

// Organize resources in a resource group
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}


module vnetOnPrem 'modules/networking/vnet.prem.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'vnetOnPrem'
  params: {
    location: location
    vnetConfiguration: vnetConfiguration
  }
}

module windows 'modules/vm/windows.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'windows'
  params: {
    adminPassword: adminPassword
    adminUsername: adminUsername
    location: location
    subnetId: vnetOnPrem.outputs.subnetId
  }
}

module servicebus 'modules/servicebus/bus.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'servicebus'
  params: {
    location: location
    suffix: suffix
  }
}

module cosmosdb 'modules/cosmosdb/cosmos.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'cosmosdb'
  params: {
    location: location
    suffix: suffix
  }
}

module monitoring 'modules/monitoring/monitoring.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'monitoring'
  params: {
    location: location
    suffix: suffix
  }
}

module storage 'modules/storage/storage.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'storage'
  params: {
    location: location
    suffix: suffix
  }
}

module function 'modules/function/function.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'function'
  params: {
    appInsightName: monitoring.outputs.appInsightName
    cosmosDbName: cosmosdb.outputs.cosmosDbName
    location: location
    serviceBusName: servicebus.outputs.namespaceName
    storageName: storage.outputs.storageName
    suffix: suffix
  }
}

module logicapp 'modules/logicapp/logicapp.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'logicapp'
  params: {
    appInsightName: monitoring.outputs.appInsightName
    location: location
    storageName: storage.outputs.storageName
    suffix: suffix
    cosmosDbName: cosmosdb.outputs.cosmosDbName
    serviceBusName: servicebus.outputs.namespaceName
  }
}

// module apim 'modules/apim/apim.bicep' = {
//   scope: resourceGroup(rg.name)
//   name: 'apim'
//   params: {    
//     location: location
//     publisherEmail: publisherEmail
//     publisherName: publisherName
//     suffix: suffix
//   }
// }
