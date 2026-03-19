// === Parameters ===
@description('The Azure region for all resources.')
param location string = resourceGroup().location

@description('The name of the Storage Account.')
param storageName string = 'stg${uniqueString(resourceGroup().id)}'

@description('Username for the Virtual Machine')
param adminUsername string = 'azureuser'

@description('Password for the Virtual Machine')
@secure()
param adminPassword string = 'AzurePass123!' // Default value for validation

// === Variables ===
var vnetName = 'VNet-Production'
var subnetName = 'MainSubnet'
var nsgName = 'NSG-Secure-Traffic'
var publicIPName = 'VM-Public-IP'
var nicName = 'VM-NIC'
var vmName = 'LinuxServer'

var defaultTags = {
  Environment: 'Learning'
  Project: 'SecureInfrastructure'
  DeployedBy: 'CloudEngineer'
}

// === Network Security Group (NSG) ===
resource nsg 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: nsgName
  location: location
  tags: defaultTags
  properties: {
    securityRules: [
      {
        name: 'AllowSSHInbound'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22' // SSH Port
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'AllowHTTPInbound'
        properties: {
          priority: 110
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

// === Virtual Network & Subnet ===
resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: vnetName
  location: location
  tags: defaultTags
  properties: {
    addressSpace: {
      addressPrefixes: ['10.0.0.0/16']
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: '10.0.1.0/24'
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
    ]
  }
}

// === Public IP Address ===
resource publicIP 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: publicIPName
  location: location
  tags: defaultTags
  sku: { name: 'Basic' }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

// === Network Interface (NIC) ===
resource nic 'Microsoft.Network/networkInterfaces@2023-05-01' = {
  name: nicName
  location: location
  tags: defaultTags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: { id: publicIP.id }
          subnet: { id: vnet.properties.subnets[0].id }
        }
      }
    ]
  }
}

// === Virtual Machine (Ubuntu Linux) ===
resource vm 'Microsoft.Network/virtualMachines@2023-09-01' = {
  name: vmName
  location: location
  tags: defaultTags
  properties: {
    hardwareProfile: { vmSize: 'Standard_B1s' }
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
        managedDisk: { storageAccountType: 'Standard_LRS' }
      }
    }
    networkProfile: {
      networkInterfaces: [{ id: nic.id }]
    }
  }
}

// === Storage Account ===
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageName
  location: location
  tags: defaultTags
  sku: { name: 'Standard_LRS' }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
  }
}

// === Resource Lock (Storage) ===
resource lockStorage 'Microsoft.Authorization/locks@2020-05-01' = {
  name: 'PreventDeleteStorage'
  scope: storageAccount
  properties: {
    level: 'CanNotDelete'
    notes: 'Locked to prevent accidental deletion.'
  }
}
