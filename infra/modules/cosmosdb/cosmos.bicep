param location string
param suffix string


resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2023-09-15' = {
  name: 'cosmosdb-${suffix}'
  location: location
  kind: 'GlobalDocumentDB'
  properties: {
    databaseAccountOfferType: 'Standard'
    locations: [
      {
        locationName: location
        failoverPriority: 0
      }    
    ]
  }
}

resource database 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2023-09-15' = {
  name: 'ais'
  parent: cosmosDbAccount
  properties: {
    resource: {
      id: 'ais'
    }
  }
}

resource container 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-09-15' = {
  name: 'request'
  parent: database
  properties: {
    resource: {
      id: 'request'
      partitionKey: {
        paths: [
          '/by'
        ]
        kind: 'Hash'
      }      
    }
    options: {
      throughput: 400
    }
  }
}


output cosmosDbName string = cosmosDbAccount.name
