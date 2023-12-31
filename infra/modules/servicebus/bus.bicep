param location string
param suffix string


resource sbNamespace 'Microsoft.ServiceBus/namespaces@2021-06-01-preview' = {
  name: 'srvbus-${suffix}'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
  properties: {}
}

resource topic 'Microsoft.ServiceBus/namespaces/topics@2021-06-01-preview' = {
  name: 'message'
  parent: sbNamespace
  properties: {}
}

resource defaultSubs 'Microsoft.ServiceBus/namespaces/topics/subscriptions@2022-10-01-preview' = {
  name: 'default'
  parent: topic
  properties: {
  }
}


output namespaceName string = sbNamespace.name
