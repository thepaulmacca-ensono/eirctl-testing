mock_provider "azurerm" {}

run "management_resource_group" {
  command = plan

  assert {
    condition     = azurerm_resource_group.management.name == "rg-management-landing-zone"
    error_message = "Resource group name must be 'rg-management-landing-zone'"
  }

  assert {
    condition     = azurerm_resource_group.management.location == "uksouth"
    error_message = "Resource group location must be 'uksouth'"
  }
}

run "log_analytics_workspace" {
  command = plan

  assert {
    condition     = azurerm_log_analytics_workspace.management.name == "law-management"
    error_message = "Log Analytics workspace name must be 'law-management'"
  }

  assert {
    condition     = azurerm_log_analytics_workspace.management.retention_in_days == 30
    error_message = "Log Analytics retention must be 30 days"
  }
}

run "automation_account" {
  command = plan

  assert {
    condition     = azurerm_automation_account.management.name == "aa-management"
    error_message = "Automation account name must be 'aa-management'"
  }

  assert {
    condition     = azurerm_automation_account.management.sku_name == "Basic"
    error_message = "Automation account SKU must be 'Basic'"
  }
}
