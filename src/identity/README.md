# Stacks Identity Landing Zone Module

## Overview

The Identity Landing Zone module deploys identity and access management
infrastructure for Azure Landing Zones. It provisions a dedicated
virtual network with subnets for Active Directory Domain Controllers and
Microsoft Entra Connect (Azure AD Connect), enabling centralized
identity management and hybrid identity scenarios.

### Purpose

- Provide a dedicated network for identity services in Azure Landing
  Zones

- Deploy subnets for Active Directory Domain Services (ADDS) domain
  controllers

- Provision a subnet for Microsoft Entra Connect (Azure AD Connect)
  servers

- Enforce network isolation for identity workloads using Network
  Security Groups

- Support hybrid identity between on-premises Active Directory and
  Microsoft Entra ID

### Key Features

- **Identity Virtual Network** — Dedicated VNet (`10.1.0.0/16`) for
  identity workloads

- **Domain Controllers Subnet** — Isolated subnet (`10.1.1.0/24`) with
  dedicated NSG for ADDS domain controllers

- **AAD Connect Subnet** — Isolated subnet (`10.1.2.0/24`) with
  dedicated NSG for Entra Connect servers

- **Network Security Groups** — Pre-configured NSGs on both identity
  subnets for traffic control

- **Peering Ready** — Designed to peer with the connectivity hub for
  cross-network identity access

## Quickstart

### Basic Usage

``` hcl
module "identity" {
  source = "./src/identity-landing-zone"

  location = "uksouth"
}
```

### Complete Example

``` hcl
provider "azurerm" {
  features {}
}

module "identity" {
  source = "./src/identity-landing-zone"

  location = "uksouth"
}

output "identity_vnet_id" {
  value = module.identity.identity_vnet_id
}

output "domain_controllers_subnet_id" {
  value = module.identity.domain_controllers_subnet_id
}

output "aad_connect_subnet_id" {
  value = module.identity.aad_connect_subnet_id
}
```

## Naming Convention

### Structure

The module follows Azure Cloud Adoption Framework naming conventions for
identity resources:

    <resource-type>-<workload>

For example: `vnet-identity`, `snet-domain-controllers`.

### Components

| Component  | Description                                |
|------------|--------------------------------------------|
| `rg-`      | Resource Group prefix                      |
| `vnet-`    | Virtual Network prefix                     |
| `snet-`    | Subnet prefix                              |
| `nsg-`     | Network Security Group prefix              |
| `identity` | Workload identifier for identity resources |

### Examples

| Resource                  | Name                       |
|---------------------------|----------------------------|
| Resource Group            | `rg-identity-landing-zone` |
| Identity Virtual Network  | `vnet-identity`            |
| Domain Controllers Subnet | `snet-domain-controllers`  |
| AAD Connect Subnet        | `snet-aad-connect`         |
| Domain Controllers NSG    | `nsg-domain-controllers`   |
| AAD Connect NSG           | `nsg-aad-connect`          |

### Workspace Naming

When deploying identity resources across multiple regions or
environments, append a suffix:

- `vnet-identity-uksouth`

- `vnet-identity-prod`

## Resource Types

The module deploys the following Azure resource types:

| Resource Type                | API Type                                            | Description                                    |
|------------------------------|-----------------------------------------------------|------------------------------------------------|
| Resource Group               | `azurerm_resource_group`                            | Container for identity resources               |
| Virtual Network              | `azurerm_virtual_network`                           | Identity VNet with address space `10.1.0.0/16` |
| Subnet (Domain Controllers)  | `azurerm_subnet`                                    | Domain Controllers subnet (`10.1.1.0/24`)      |
| Subnet (AAD Connect)         | `azurerm_subnet`                                    | Microsoft Entra Connect subnet (`10.1.2.0/24`) |
| Network Security Group (DC)  | `azurerm_network_security_group`                    | NSG for Domain Controllers subnet              |
| Network Security Group (AAD) | `azurerm_network_security_group`                    | NSG for AAD Connect subnet                     |
| NSG Association (DC)         | `azurerm_subnet_network_security_group_association` | Associates NSG with Domain Controllers subnet  |
| NSG Association (AAD)        | `azurerm_subnet_network_security_group_association` | Associates NSG with AAD Connect subnet         |

## Advanced Usage

### Peering with Connectivity Hub

Peer the identity VNet with the connectivity hub for cross-network
access:

``` hcl
resource "azurerm_virtual_network_peering" "identity_to_hub" {
  name                      = "peer-identity-to-hub"
  resource_group_name       = module.identity.resource_group_name
  virtual_network_name      = module.identity.identity_vnet_name
  remote_virtual_network_id = module.hub.hub_vnet_id

  allow_forwarded_traffic = true
  allow_gateway_transit   = false
  use_remote_gateways     = true
}
```

### Custom NSG Rules

Add custom NSG rules to allow specific identity traffic patterns:

- **LDAP** — TCP/UDP 389 for directory queries

- **LDAPS** — TCP 636 for secure directory queries

- **Kerberos** — TCP/UDP 88 for authentication

- **DNS** — TCP/UDP 53 for name resolution

- **RPC** — TCP 135 and dynamic ports for AD replication

### Multi-Region Identity

For disaster recovery, deploy identity infrastructure in a secondary
region with AD replication:

``` hcl
module "identity_primary" {
  source   = "./src/identity-landing-zone"
  location = "uksouth"
}

module "identity_secondary" {
  source   = "./src/identity-landing-zone"
  location = "ukwest"
}
```

<div class="note">

Configure AD Sites and Services to manage replication between regions.

</div>

### Environment File Configuration

The module uses an `eirctl.env` file for environment-specific settings:

``` bash
TF_FILE_LOCATION=.
ENVIRONMENT_NAME=dev
TF_BACKEND_RG=rg-tfstate
TF_BACKEND_SA=satfstate
TF_BACKEND_CONTAINER=tfstate
TF_BACKEND_KEY=identity.tfstate
```

### Azure Policy for Identity

Apply Azure Policy to enforce identity security standards:

- **Require NSG on Identity Subnets** — Ensure all identity subnets have
  associated NSGs

- **Deny Public IP on Identity VMs** — Prevent domain controllers from
  having public endpoints

- **Audit Identity VNet Peering** — Monitor peering configurations for
  unauthorised connections

## Best Practices

### Resource Naming

Follow Azure Cloud Adoption Framework naming conventions. Use `vnet-`
for virtual networks, `snet-` for subnets, `nsg-` for network security
groups, and `rg-` for resource groups.

### Identity Isolation

Keep identity workloads in a dedicated subscription and VNet, separate
from application workloads. Peer with the connectivity hub and use NSG
rules to restrict access to identity ports only.

### Domain Controller Placement

Deploy at least two domain controllers across availability zones for
high availability. Place them in the Domain Controllers subnet with the
pre-configured NSG.

### Hybrid Identity

When using Microsoft Entra Connect, deploy it in the dedicated AAD
Connect subnet. Ensure the server has connectivity to both on-premises
AD and Microsoft Entra ID endpoints.

### Region Selection

Deploy identity resources in the same region as your primary
connectivity hub. For multi-region deployments, deploy domain
controllers in each region and configure AD Sites and Services for
efficient replication.

## Migration Guide

### Importing Existing Identity Infrastructure

Import existing identity networking resources into Terraform state:

``` bash
terraform import azurerm_virtual_network.identity /subscriptions/<sub-id>/resourceGroups/rg-identity-landing-zone/providers/Microsoft.Network/virtualNetworks/vnet-identity

terraform import azurerm_subnet.domain_controllers /subscriptions/<sub-id>/resourceGroups/rg-identity-landing-zone/providers/Microsoft.Network/virtualNetworks/vnet-identity/subnets/snet-domain-controllers
```

<div class="note">

Import all associated NSGs and NSG associations to maintain a consistent
state.

</div>

### Migrating to Microsoft Entra Domain Services

If migrating from self-managed ADDS to Microsoft Entra Domain Services:

1.  Deploy Microsoft Entra Domain Services in the domain controllers
    subnet

2.  Synchronise users and groups from on-premises AD via Entra Connect

3.  Update application configurations to use the managed domain

4.  Decommission self-managed domain controllers in phases

## Troubleshooting

### NSG Rule Conflicts

If domain controllers cannot communicate, verify that NSG rules allow
the required AD ports (LDAP 389, Kerberos 88, DNS 53, RPC 135). Check
both the source and destination NSGs for conflicting deny rules.

### VNet Peering Connectivity

If identity services are unreachable from spoke VNets, verify that:

- VNet peering is established between identity and hub VNets

- `AllowForwardedTraffic` is enabled on the peering

- NSG rules permit traffic from spoke address ranges

### Address Space Overlap

If you see `AddressSpaceOverlap` when peering the identity VNet, ensure
the identity address space (`10.1.0.0/16`) does not overlap with the hub
VNet or other peered networks.

### Subnet Delegation Conflicts

If deploying managed services (e.g., Entra Domain Services) into
identity subnets, check that no conflicting subnet delegations exist.
Some services require exclusive subnet delegation.

## Examples

### Basic Identity Deployment

A minimal identity landing zone deployment:

``` hcl
module "identity" {
  source   = "./src/identity-landing-zone"
  location = "uksouth"
}
```

### Identity with Hub Peering

Deploy identity infrastructure peered to the connectivity hub:

``` hcl
module "hub" {
  source   = "./src/connectivity-landing-zone-hub-spoke"
  location = "uksouth"
}

module "identity" {
  source   = "./src/identity-landing-zone"
  location = "uksouth"
}

resource "azurerm_virtual_network_peering" "identity_to_hub" {
  name                      = "peer-identity-to-hub"
  resource_group_name       = module.identity.resource_group_name
  virtual_network_name      = module.identity.identity_vnet_name
  remote_virtual_network_id = module.hub.hub_vnet_id
}

resource "azurerm_virtual_network_peering" "hub_to_identity" {
  name                      = "peer-hub-to-identity"
  resource_group_name       = module.hub.resource_group_name
  virtual_network_name      = module.hub.hub_vnet_name
  remote_virtual_network_id = module.identity.identity_vnet_id
}
```

### Multi-Region Identity

Deploy identity infrastructure in two regions for AD replication:

``` hcl
module "identity_primary" {
  source   = "./src/identity-landing-zone"
  location = "uksouth"
}

module "identity_secondary" {
  source   = "./src/identity-landing-zone"
  location = "ukwest"
}
```

## API Reference

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name                                                                         | Version   |
|------------------------------------------------------------------------------|-----------|
| <span id="requirement_terraform"></span> [terraform](#requirement_terraform) | ~> 1.12  |
| <span id="requirement_azurerm"></span> [azurerm](#requirement_azurerm)       | ~> 4.1.0 |

## Providers

| Name                                                             | Version   |
|------------------------------------------------------------------|-----------|
| <span id="provider_azurerm"></span> [azurerm](#provider_azurerm) | ~> 4.1.0 |

## Modules

No modules.

## Resources

| Name                                                                                                                                                                                              | Type     |
|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|
| [azurerm_network_security_group.aad_connect](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group)                                              | resource |
| [azurerm_network_security_group.domain_controllers](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group)                                       | resource |
| [azurerm_resource_group.identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group)                                                                 | resource |
| [azurerm_subnet.aad_connect](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet)                                                                              | resource |
| [azurerm_subnet.domain_controllers](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet)                                                                       | resource |
| [azurerm_subnet_network_security_group_association.aad_connect](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association)        | resource |
| [azurerm_subnet_network_security_group_association.domain_controllers](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_virtual_network.identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network)                                                               | resource |

## Inputs

| Name                                                                                           | Description                          | Type     | Default | Required |
|------------------------------------------------------------------------------------------------|--------------------------------------|----------|---------|----------|
| <span id="input_resource_group_name"></span> [resource_group_name](#input_resource_group_name) | Name of the resource group to create | `string` | n/a     | yes      |

## Outputs

| Name                                                                                             | Description                                                      |
|--------------------------------------------------------------------------------------------------|------------------------------------------------------------------|
| <span id="output_resource_group_name"></span> [resource_group_name](#output_resource_group_name) | Name of the resource group created for the Identity landing zone |

<!-- END_TF_DOCS -->

## Support

For issues, questions, or contributions related to this module, please
contact the Ensono Stacks team.

## License

Copyright (c) 2025 Ensono

This project is licensed under the MIT License.
