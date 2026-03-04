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

# Management resource group
resource "azurerm_resource_group" "management" {
  name     = "rg-management-lz"
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

# Automation Account for runbooks
resource "azurerm_automation_account" "management" {
  name                = "aa-management"
  location            = azurerm_resource_group.management.location
  resource_group_name = azurerm_resource_group.management.name
  sku_name            = "Basic"
}
