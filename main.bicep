// Ορισμός τοποθεσίας
param location string = 'westeurope'

// Δημιουργία Storage Account (Storage)
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: 'stjunior${uniqueString(resourceGroup().id)}'
  location: location
  sku: { name: 'Standard_LRS' }
  kind: 'StorageV2'
}

// Δημιουργία Virtual Network (Networking)
resource vnet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: 'VNet-Project'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: ['10.0.0.0/16']
    }
    subnets: [
      {
        name: 'MainSubnet'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
    ]
  }
}
