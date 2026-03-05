mock_provider "azurerm" {}

run "management_resource_group" {
  command = plan

  assert {
    condition     = azurerm_resource_group.management.name == "rg-management"
    error_message = "Resource group name must be 'rg-management'"
  }

  assert {
    condition     = azurerm_resource_group.management.location == "uksouth"
    error_message = "Resource group location must be 'uksouth'"
  }
}

run "log_analytics_workspace" {
  command = plan

  assert {
    condition     = azurerm_log_analytics_workspace.management.name == "log-management"
    error_message = "Log Analytics workspace name must be 'log-management'"
  }

  assert {
    condition     = azurerm_log_analytics_workspace.management.retention_in_days == 30
    error_message = "Log Analytics retention must be 30 days"
  }

  assert {
    condition     = azurerm_log_analytics_workspace.management.retention_in_days == 90
    error_message = "Log Analytics retention must be 90 days"
  }
}
