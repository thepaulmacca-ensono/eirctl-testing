# Connectivity Landing Zone - Virtual WAN Model
terraform {
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

# Virtual WAN resource group
resource "azurerm_resource_group" "vwan" {
  name     = "rg-connectivity-vwan"
  location = "uksouth"
}

# Virtual WAN
resource "azurerm_virtual_wan" "vwan" {
  name                = "vwan-connectivity"
  resource_group_name = azurerm_resource_group.vwan.name
  location            = azurerm_resource_group.vwan.location
  type                = "Standard"
}

# Virtual Hub
resource "azurerm_virtual_hub" "hub" {
  name                = "vhub-uksouth"
  resource_group_name = azurerm_resource_group.vwan.name
  location            = azurerm_resource_group.vwan.location
  virtual_wan_id      = azurerm_virtual_wan.vwan.id
  address_prefix      = "10.0.0.0/23"
}
