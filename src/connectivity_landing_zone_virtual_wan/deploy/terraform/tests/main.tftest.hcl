mock_provider "azurerm" {}

run "vwan_resource_group" {
  command = plan

  assert {
    condition     = azurerm_resource_group.vwan.name == "rg-connectivity-vwan"
    error_message = "Resource group name must be 'rg-connectivity-vwan'"
  }

  assert {
    condition     = azurerm_resource_group.vwan.location == "uksouth"
    error_message = "Resource group location must be 'uksouth'"
  }
}

run "virtual_wan" {
  command = plan

  assert {
    condition     = azurerm_virtual_wan.vwan.name == "vwan-connectivity"
    error_message = "Virtual WAN name must be 'vwan-connectivity'"
  }

  assert {
    condition     = azurerm_virtual_wan.vwan.type == "Standard"
    error_message = "Virtual WAN type must be 'Standard'"
  }
}

run "virtual_hub" {
  command = plan

  assert {
    condition     = azurerm_virtual_hub.hub.name == "vhub-uksouth"
    error_message = "Virtual Hub name must be 'vhub-uksouth'"
  }

  assert {
    condition     = azurerm_virtual_hub.hub.address_prefix == "10.0.0.0/23"
    error_message = "Virtual Hub address prefix must be '10.0.0.0/23'"
  }
}
