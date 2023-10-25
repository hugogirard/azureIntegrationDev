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
