# Stacks Azure Platform Landing Zone - Connectivity (Virtual WAN)

This module deploys connectivity resources using Azure Virtual WAN. It provides a Microsoft-managed global transit network architecture for Azure Landing Zones with simplified any-to-any connectivity.

## Architecture

```mermaid
flowchart TB
    subgraph Connectivity["Connectivity Subscription"]
        direction TB

        subgraph VWAN["Azure Virtual WAN"]
            HUB1["Virtual Hub - Region 1"]
            HUB2["Virtual Hub - Region 2"]
        end

        subgraph Connected["Connected Networks"]
            VNET1["Virtual Network 1"]
            VNET2["Virtual Network 2"]
            VPN["VPN Site"]
            ER["ExpressRoute Circuit"]
        end
    end

    HUB1 <--> HUB2
    HUB1 <--> VNET1
    HUB1 <--> VNET2
    HUB1 <--> VPN
    HUB2 <--> ER
```

## Features

| Feature | Default | Description |
| ------- | ------- | ----------- |
| Virtual WAN | ✅ | Global transit network |
| Virtual Hub | ✅ | Regional hub for connectivity |
| Azure Firewall | ❌ | Secured Virtual Hub |
| VPN Gateway | ❌ | Site-to-site VPN connectivity |
| ExpressRoute Gateway | ❌ | Private connectivity to on-premises |
| P2S VPN | ❌ | Point-to-site VPN for users |
| Routing Intent | ❌ | Centralized routing policies |

## Usage

```hcl
module "connectivity_vwan" {
  source = "./deploy/terraform"

  company_name        = "ensono"
  environment         = "dev"
  location            = "uksouth"
  virtual_wan_type    = "Standard"
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.9 |
| azurerm | ~> 4.1.0 |
