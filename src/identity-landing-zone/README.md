# Stacks Azure Platform Landing Zone - Identity

This module deploys identity resources for Azure Landing Zones. It provides Active Directory Domain Services (ADDS), Microsoft Entra Domain Services, or hybrid identity components for centralized identity management.

## Architecture

```mermaid
flowchart TB
    subgraph Identity["Identity Subscription"]
        direction TB

        subgraph Network["Identity Network"]
            VNET["Identity VNet"]
            SUBNET["Domain Controllers Subnet"]
        end

        subgraph DomainControllers["Domain Controllers"]
            DC1["Domain Controller 1"]
            DC2["Domain Controller 2"]
        end

        subgraph EntraDS["Microsoft Entra DS (Optional)"]
            AADDS["Entra Domain Services"]
        end
    end

    subgraph OnPrem["On-Premises"]
        ADDS["Active Directory"]
    end

    VNET --> SUBNET
    SUBNET --> DC1
    SUBNET --> DC2
    DC1 <--> ADDS
    DC2 <--> ADDS
```

## Features

| Feature | Default | Description |
| ------- | ------- | ----------- |
| Identity VNet | ✅ | Dedicated network for identity services |
| Domain Controller VMs | ❌ | Windows Server VMs for AD DS |
| Microsoft Entra DS | ❌ | Managed domain services |
| DNS Configuration | ❌ | Private DNS zones for domain resolution |
| Key Vault | ❌ | Secrets storage for credentials |
| Backup | ❌ | Recovery Services vault for DCs |

## Usage

```hcl
module "identity" {
  source = "./deploy/terraform"

  company_name        = "ensono"
  environment         = "dev"
  location            = "uksouth"
  address_space       = ["10.1.0.0/16"]
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.9 |
| azurerm | ~> 4.1.0 |
