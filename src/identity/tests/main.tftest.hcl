mock_provider "azurerm" {}

variables {
  resource_group_name = "rg-management"
}

run "identity_resource_group" {
  command = plan

  assert {
    condition     = azurerm_resource_group.identity.name == var.resource_group_name
    error_message = "Resource group name must be '${var.resource_group_name}'"
  }

  assert {
    condition     = azurerm_resource_group.identity.location == "uksouth"
    error_message = "Resource group location must be 'uksouth'"
  }
}

run "identity_virtual_network" {
  command = plan

  assert {
    condition     = azurerm_virtual_network.identity.name == "vnet-identity"
    error_message = "Identity VNet name must be 'vnet-identity'"
  }

  assert {
    condition     = contains(azurerm_virtual_network.identity.address_space, "10.1.0.0/16")
    error_message = "Identity VNet address space must contain '10.1.0.0/16'"
  }
}

run "domain_controllers_subnet" {
  command = plan

  assert {
    condition     = azurerm_subnet.domain_controllers.name == "snet-domain-controllers"
    error_message = "Domain controllers subnet must be named 'snet-domain-controllers'"
  }

  assert {
    condition     = contains(azurerm_subnet.domain_controllers.address_prefixes, "10.1.1.0/24")
    error_message = "Domain controllers subnet must use '10.1.1.0/24'"
  }
}

run "aad_connect_subnet" {
  command = plan

  assert {
    condition     = azurerm_subnet.aad_connect.name == "snet-aad-connect"
    error_message = "AAD Connect subnet must be named 'snet-aad-connect'"
  }

  assert {
    condition     = contains(azurerm_subnet.aad_connect.address_prefixes, "10.1.2.0/24")
    error_message = "AAD Connect subnet must use '10.1.2.0/24'"
  }
}
