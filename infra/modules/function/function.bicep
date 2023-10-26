param location string
param suffix string
param storageName string
param appInsightName string
param cosmosDbName string
param serviceBusName string

resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' existing = {
  name: appInsightName
}

resource storage 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
  name: storageName
}

resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2023-09-15' existing = {
  name: cosmosDbName
}

resource namespace 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' existing = {
  name: serviceBusName 
}

// We return the default authorization rules from ServiceBus
resource defaultAuthorizationRules 'Microsoft.ServiceBus/namespaces/AuthorizationRules@2022-10-01-preview' existing = {
  name: 'RootManageSharedAccessKey'
  parent: namespace
}

resource serverFarm 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: 'asp-${suffix}'
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
  kind: 'functionapp'
  properties: {    
  }
}

resource functionHl7 'Microsoft.Web/sites@2022-09-01' = {
  name: 'funcdemo-${suffix}'
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: serverFarm.id
    siteConfig: {
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsights.properties.ConnectionString
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storage.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storage.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storage.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storage.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: 'funcblobapp09'
        }
        {
          name: 'CosmosDb'
          value: 'ais'
        }
        {
          name: 'CosmosContainerOut'
          value: 'request'
        }
        {          
          name: 'CosmosDBConnection'
          value: 'https://${cosmosDbAccount.name}.documents.azure.com:43/;AccountKey=${cosmosDbAccount.listKeys().primaryMasterKey};'
        }
        {
          name: 'outputTopic'
          value: 'message'
        }
        {
          name: 'ServiceBusConnection'
          value: defaultAuthorizationRules.listKeys().primaryConnectionString
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet-isolated'
        }

      ]
      netFrameworkVersion: 'v7.0'
    }    
  }
}
