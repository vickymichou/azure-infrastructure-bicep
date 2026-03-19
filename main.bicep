var defaultTags = {
  Environment: 'Learning'
  Project: 'SecureStorage'
  Owner: 'CloudEngineer' // 
}

// Αντί για σταθερά ονόματα, χρησιμοποιούμε μεταβλητές
// Parameters
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
  tags: defaultTags //
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

resource lockStorage 'Microsoft.Authorization/locks@2020-05-01' = {
  name: 'PreventDelete'
  scope: storageAccount // Συνδέεται με το όνομα που έδωσες στο storage resource
  properties: {
    level: 'CanNotDelete'
    notes: 'This resource is locked to prevent accidental deletion.'
  }
}

// === Parameters for VM ===
@description('Username for the Virtual Machine')
param adminUsername string = 'azureuser'

@description('Password for the Virtual Machine')
@secure() // Αυτό κρύβει τον κωδικό από τα logs!
param adminPassword string

// === Public IP ===
resource publicIP 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: 'vm-public-ip'
  location: location
  tags: defaultTags
  sku: {
    name: 'Basic'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

// === Network Interface (NIC) ===
resource nic 'Microsoft.Network/networkInterfaces@2023-05-01' = {
  name: 'vm-nic'
  location: location
  tags: defaultTags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIP.id
          }
          subnet: {
            id: vnet.properties.subnets[0].id // Συνδέεται με το Subnet που ήδη έχεις
          }
        }
      }
    ]
  }
}

// === Virtual Machine ===
resource vm 'Microsoft.Network/virtualMachines@2023-09-01' = {
  name: 'LinuxServer'
  location: location
  tags: defaultTags
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1s' // Πολύ οικονομικό μέγεθος
    }
    osProfile: {
      computerName: 'linuxserver'
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}
