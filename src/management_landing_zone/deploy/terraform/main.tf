# Management Landing Zone Module

variable "unused_tflint_test" {
  description = "Unused variable to trigger tflint failure"
  type        = string
  default     = "this-should-fail-tflint"
}

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
#
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
