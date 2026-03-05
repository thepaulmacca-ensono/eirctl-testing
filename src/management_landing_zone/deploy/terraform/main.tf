# Management Landing Zone Module
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

# Management Resource Group
resource "azurerm_resource_group" "management" {
  name     = "rg-management"
  location = "uksouth"
}

# Log Analytics Workspace for centralized logging
resource "azurerm_log_analytics_workspace" "management" {
  name                = "log-management"
  location            = azurerm_resource_group.management.location
  resource_group_name = azurerm_resource_group.management.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Storage Account - deliberately insecure for checkov testing
resource "azurerm_storage_account" "management" {
  name                            = "stmanagement"
  location                        = azurerm_resource_group.management.location
  resource_group_name             = azurerm_resource_group.management.name
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  https_traffic_only_enabled      = false
  allow_nested_items_to_be_public = true
}
