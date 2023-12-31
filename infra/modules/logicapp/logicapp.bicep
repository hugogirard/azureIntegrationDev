param location string
param storageName string
param appInsightName string
param suffix string
param cosmosDbName string
param serviceBusName string

resource storageLogicApp 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
  name: storageName
}

resource insight 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsightName
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


resource hostingPlanFE 'Microsoft.Web/serverfarms@2018-11-01' = {
  name: 'aspl-${suffix}'
  location: location
  sku: {
    tier: 'WorkflowStandard'
    name: 'WS1'
  }
  kind: ''
}

resource logiapp 'Microsoft.Web/sites@2021-02-01' = {
  name: 'logi-${suffix}'
  location: location
  kind: 'workflowapp,functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {    
    siteConfig: {
      netFrameworkVersion: 'v6.0'      
      appSettings: [
        {
          name: 'APP_KIND'
          value: 'workflowApp'
        }       
        {
          name: 'AzureCosmosDB_connectionString'
          value: 'AccountEndpoint=https://${cosmosDbAccount.name}.documents.azure.com:443/;AccountKey=${cosmosDbAccount.listKeys().primaryMasterKey};'
        }
        {
          name: 'serviceBus_connectionString'
          value: defaultAuthorizationRules.listKeys().primaryConnectionString
        }
        {
          name: 'AzureFunctionsJobHost__extensionBundle__id'
          value: 'Microsoft.Azure.Functions.ExtensionBundle.Workflows'
        }
        {
          name: 'AzureFunctionsJobHost__extensionBundle__version'
          value: '[1.*, 2.0.0)'
        }         
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'node'
        }
        {
          name: 'FUNCTIONS_V2_COMPATIBILITY_MODE'
          value: 'true'
        }     
        {
          name: 'WORKFLOWS_SUBSCRIPTION_ID'
          value: subscription().subscriptionId
        }
        {
          name: 'WORKFLOWS_LOCATION_NAME'
          value: location
        }
        {
          name: 'WORKFLOWS_RESOURCE_GROUP_NAME'
          value: resourceGroup().name
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~18'
        }      
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: insight.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: insight.properties.ConnectionString
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageLogicApp.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageLogicApp.id, storageLogicApp.apiVersion).keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageLogicApp.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageLogicApp.id, storageLogicApp.apiVersion).keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: 'logicapp87'
        }
      ]
      use32BitWorkerProcess: true
    }
    serverFarmId: hostingPlanFE.id
    clientAffinityEnabled: false    
  }
}
