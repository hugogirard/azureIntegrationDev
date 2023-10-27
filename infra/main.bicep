targetScope = 'subscription'

// The main bicep module to provision Azure resources.
// For a more complete walkthrough to understand how this file works with azd,
// see https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/make-azd-compatible?pivots=azd-create

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

@description('Email address of the publisher for APIM')
@secure()
param publisherEmail string

@description('Publisher Name')
@secure()
param publisherName string


var suffix = toLower(uniqueString(rg.name))

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
