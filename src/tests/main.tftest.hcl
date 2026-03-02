mock_provider "azurerm" {}

run "resource_group_name" {
  command = plan

  assert {
    condition     = azurerm_resource_group.example.name == "rg-example-resources"
    error_message = "Resource group name must be 'rg-example-resources'"
  }

  assert {
    condition     = azurerm_resource_group.example.location == "uksouth"
    error_message = "Resource group location must be 'uksouth'"
  }
}

run "virtual_network_configuration" {
  command = plan

  assert {
    condition     = azurerm_virtual_network.example.name == "vnet-example-network"
    error_message = "Virtual network name must be 'vnet-example-network'"
  }

  assert {
    condition     = contains(azurerm_virtual_network.example.address_space, "10.0.0.0/16")
    error_message = "Virtual network address space must contain '10.0.0.0/16'"
  }
}
