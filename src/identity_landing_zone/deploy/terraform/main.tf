# Identity Landing Zone Module
terraform {
  required_version = "~> 1.12"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.1.0"
    }
  }
}

provider "azurerm" {
  resource_provider_registrations = "none"
  features {}
}

# Identity resource group
resource "azurerm_resource_group" "identity" {
  name     = "rg-identity-landing-zone"
  location = "uksouth"
}

# Virtual Network for identity workloads
resource "azurerm_virtual_network" "identity" {
  name                = "vnet-identity"
  resource_group_name = azurerm_resource_group.identity.name
  location            = azurerm_resource_group.identity.location
  address_space       = ["10.1.0.0/16"]
}

# Domain Controllers NSG
resource "azurerm_network_security_group" "domain_controllers" {
  name                = "nsg-domain-controllers"
  resource_group_name = azurerm_resource_group.identity.name
  location            = azurerm_resource_group.identity.location
}

# Subnet for Domain Controllers
resource "azurerm_subnet" "domain_controllers" {
  name                 = "snet-domain-controllers"
  resource_group_name  = azurerm_resource_group.identity.name
  virtual_network_name = azurerm_virtual_network.identity.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "domain_controllers" {
  subnet_id                 = azurerm_subnet.domain_controllers.id
  network_security_group_id = azurerm_network_security_group.domain_controllers.id
}

# Azure AD Connect NSG
resource "azurerm_network_security_group" "aad_connect" {
  name                = "nsg-aad-connect"
  resource_group_name = azurerm_resource_group.identity.name
  location            = azurerm_resource_group.identity.location
}

# Subnet for Azure AD Connect
resource "azurerm_subnet" "aad_connect" {
  name                 = "snet-aad-connect"
  resource_group_name  = azurerm_resource_group.identity.name
  virtual_network_name = azurerm_virtual_network.identity.name
  address_prefixes     = ["10.1.2.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "aad_connect" {
  subnet_id                 = azurerm_subnet.aad_connect.id
  network_security_group_id = azurerm_network_security_group.aad_connect.id
}
