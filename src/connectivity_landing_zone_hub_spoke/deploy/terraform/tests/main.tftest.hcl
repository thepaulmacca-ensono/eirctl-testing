mock_provider "azurerm" {}

run "hub_resource_group" {
  command = plan

  assert {
    condition     = azurerm_resource_group.hub.name == "rg-connectivity-hub"
    error_message = "Resource group name must be 'rg-connectivity-hub'"
  }

  assert {
    condition     = azurerm_resource_group.hub.location == "uksouth"
    error_message = "Resource group location must be 'uksouth'"
  }
}

run "hub_virtual_network" {
  command = plan

  assert {
    condition     = azurerm_virtual_network.hub.name == "vnet-hub"
    error_message = "Hub VNet name must be 'vnet-hub'"
  }

  assert {
    condition     = contains(azurerm_virtual_network.hub.address_space, "10.0.0.0/16")
    error_message = "Hub VNet address space must contain '10.0.0.0/16'"
  }
}

run "gateway_subnet" {
  command = plan

  assert {
    condition     = azurerm_subnet.gateway.name == "GatewaySubnet"
    error_message = "Gateway subnet must be named 'GatewaySubnet'"
  }

  assert {
    condition     = contains(azurerm_subnet.gateway.address_prefixes, "10.0.1.0/24")
    error_message = "Gateway subnet must use '10.0.1.0/24'"
  }
}

run "firewall_subnet" {
  command = plan

  assert {
    condition     = azurerm_subnet.firewall.name == "AzureFirewallSubnet"
    error_message = "Firewall subnet must be named 'AzureFirewallSubnet'"
  }
}

run "bastion_subnet" {
  command = plan

  assert {
    condition     = azurerm_subnet.bastion.name == "AzureBastionSubnet"
    error_message = "Bastion subnet must be named 'AzureBastionSubnet'"
  }
}
