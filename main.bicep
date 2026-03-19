// Αντί για σταθερά ονόματα, χρησιμοποιούμε μεταβλητές
param location string = 'westeurope'
param storageName string = 'stjunior${uniqueString(resourceGroup().id)}'
param vnetName string = 'VNet-Project-Secure'

// --- NETWORK SECURITY GROUP (Firewall) ---
// Αυτό ορίζει ποιος επιτρέπεται να "μπει" στο δίκτυο
resource nsg 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: 'MyNetwork-FG'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowHTTP'
        properties: {
          priority: 100
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80' // Επιτρέπουμε την κίνηση Web
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

// --- STORAGE ACCOUNT ---
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageName
  location: location
  sku: { name: 'Standard_LRS' }
  kind: 'StorageV2'
}

// --- VIRTUAL NETWORK ---
resource vnet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: vnetName
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
          // Εδώ συνδέουμε το Firewall (NSG) με το Subnet!
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
    ]
  }
}
