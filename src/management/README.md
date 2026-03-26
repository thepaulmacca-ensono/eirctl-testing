# Stacks Management Landing Zone Module

## Overview

The Management Landing Zone module deploys centralized logging,
monitoring, and management resources for Azure Landing Zones. It
provisions a dedicated resource group and Log Analytics Workspace for
aggregating logs and metrics across your Azure estate.

### Purpose

- Provide a centralized management subscription for logging and
  monitoring

- Deploy a Log Analytics Workspace for aggregating platform and workload
  logs

- Establish a consistent resource group for management resources

- Support Azure Monitor and Microsoft Defender for Cloud integration

- Enable governance and compliance through centralized log retention
  policies

### Key Features

- **Log Analytics Workspace** — Centralized log aggregation using the
  PerGB2018 pricing tier

- **Configurable Retention** — Default 30-day log retention with
  adjustable policies

- **Resource Group** — Dedicated `rg-management` resource group for
  management resources

- **Azure Verified Modules** — Built using AVM patterns for consistency
  and supportability

- **Platform Integration** — Ready for Azure Monitor, Sentinel, and
  Defender for Cloud

## Quickstart

### Basic Usage

``` hcl
module "management" {
  source = "./src/management-landing-zone"

  location = "uksouth"
}
```

### Complete Example

``` hcl
provider "azurerm" {
  features {}
}

module "management" {
  source = "./src/management-landing-zone"

  location = "uksouth"
}

output "resource_group_name" {
  value = module.management.resource_group_name
}

output "log_analytics_workspace_id" {
  value = module.management.log_analytics_workspace_id
}
```

## Naming Convention

### Structure

The module follows Azure naming conventions from the Cloud Adoption
Framework:

    <resource-type>-<workload>

For example: `rg-management`, `log-management`.

### Components

| Component    | Description                                  |
|--------------|----------------------------------------------|
| `rg-`        | Resource Group prefix                        |
| `log-`       | Log Analytics Workspace prefix               |
| `management` | Workload identifier for management resources |

### Examples

| Resource                | Name             |
|-------------------------|------------------|
| Resource Group          | `rg-management`  |
| Log Analytics Workspace | `log-management` |

### Workspace Naming

The Log Analytics Workspace name must be globally unique within Azure.
Consider appending an environment or region suffix if deploying multiple
instances:

- `log-management-uksouth`

- `log-management-prod`

## Resource Types

The module deploys the following Azure resource types:

| Resource Type           | API Type                          | Description                                     |
|-------------------------|-----------------------------------|-------------------------------------------------|
| Resource Group          | `azurerm_resource_group`          | Container for all management resources          |
| Log Analytics Workspace | `azurerm_log_analytics_workspace` | Centralized log aggregation and query workspace |

``` hcl
resource "azurerm_resource_group" "management" {
  name     = "rg-management"
  location = var.location
}

resource "azurerm_log_analytics_workspace" "management" {
  name                = "log-management"
  location            = azurerm_resource_group.management.location
  resource_group_name = azurerm_resource_group.management.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}
```

## Advanced Usage

### Multi-Subscription Deployment

Deploy management resources to a dedicated management subscription while
collecting logs from workload subscriptions:

``` hcl
provider "azurerm" {
  alias           = "management"
  subscription_id = var.management_subscription_id
  features {}
}

module "management" {
  source = "./src/management-landing-zone"

  providers = {
    azurerm = azurerm.management
  }

  location = "uksouth"
}
```

### Custom Retention Periods

Adjust the Log Analytics Workspace retention period based on compliance
requirements:

- 30 days — Default for development environments

- 90 days — Recommended for production workloads

- 365 days — Required for some regulatory frameworks

- 730 days — Maximum retention period supported

### Multi-Region Logging

For multi-region deployments, consider deploying a Log Analytics
Workspace per region to reduce data egress costs and improve query
performance. Use Azure Monitor data collection rules to route logs to
the appropriate workspace.

### Environment File Configuration

The module uses an `eirctl.env` file for environment-specific settings:

``` bash
TF_FILE_LOCATION=.
ENVIRONMENT_NAME=dev
TF_BACKEND_RG=rg-tfstate
TF_BACKEND_SA=satfstate
TF_BACKEND_CONTAINER=tfstate
TF_BACKEND_KEY=management.tfstate
```

### Azure Policy Integration

Assign Azure Policy to enforce diagnostic settings across your
management subscription:

- **Deploy Diagnostic Settings** — Automatically send platform logs to
  the Log Analytics Workspace

- **Require Log Analytics Workspace** — Ensure all resources have
  diagnostic settings configured

- **Audit Log Retention** — Verify retention policies meet compliance
  requirements

## Best Practices

### Resource Naming

Follow Azure Cloud Adoption Framework naming conventions. Use the `rg-`
prefix for resource groups and `log-` prefix for Log Analytics
Workspaces.

### Workspace Design

Use a single centralized Log Analytics Workspace for platform logs.
Separate workspaces may be appropriate for workload-specific logging
with different retention requirements.

### Organisation Prefix

Consider including an organisation prefix in resource names to avoid
conflicts in shared environments:

- `log-contoso-management`

- `rg-contoso-management`

### Project Identification

Tag all management resources with project and cost centre identifiers to
support chargeback and governance reporting.

### Region Selection

Deploy management resources in the same region as your primary workloads
to minimise latency. For multi-region deployments, deploy a workspace
per region and use cross-workspace queries to correlate data.

## Migration Guide

### Migrating Existing Log Analytics Workspaces

If you have an existing Log Analytics Workspace, import it into
Terraform state:

``` bash
terraform import azurerm_log_analytics_workspace.management /subscriptions/<sub-id>/resourceGroups/rg-management/providers/Microsoft.OperationalInsights/workspaces/log-management
```

<div class="note">

Ensure the resource configuration in Terraform matches the existing
workspace settings before importing.

</div>

### Migrating from Legacy Pricing Tiers

If your existing workspace uses the legacy Free, Standard, or Premium
pricing tiers, migrate to PerGB2018:

1.  Update the `sku` parameter in your Terraform configuration

2.  Run `terraform plan` to verify the change

3.  Apply the change during a maintenance window

## Troubleshooting

### Workspace Name Length

Log Analytics Workspace names must be between 4 and 63 characters. If
you receive a validation error, check that your workspace name
(including any prefix or suffix) falls within this range.

### Invalid Region

If you see `InvalidLocation` errors, verify that Log Analytics is
available in your target region. Some regions may have limited service
availability. Check the [Azure products by
region](https://azure.microsoft.com/en-gb/explore/global-infrastructure/products-by-region/)
page.

### Name Already Exists

Log Analytics Workspace names must be globally unique. If you receive a
`ConflictError`, choose a more specific name by appending environment or
region identifiers.

### Provider Not Registered

If you see `MissingSubscriptionRegistration`, register the required
resource provider:

``` bash
az provider register --namespace Microsoft.OperationalInsights
```

## Examples

### Basic Management Deployment

A minimal deployment with default settings:

``` hcl
module "management" {
  source   = "./src/management-landing-zone"
  location = "uksouth"
}
```

### Management with Extended Retention

Deploy management resources with a 90-day retention period for
production environments:

``` hcl
module "management" {
  source            = "./src/management-landing-zone"
  location          = "uksouth"
  retention_in_days = 90
}
```

### Multi-Region Management

Deploy management resources across multiple regions:

``` hcl
module "management_uk" {
  source   = "./src/management-landing-zone"
  location = "uksouth"
}

module "management_eu" {
  source   = "./src/management-landing-zone"
  location = "westeurope"
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

| Name                                                                                                                                                  | Type     |
|-------------------------------------------------------------------------------------------------------------------------------------------------------|----------|
| [azurerm_log_analytics_workspace.management](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_resource_group.management](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group)                   | resource |

## Inputs

| Name                                                                                           | Description                          | Type     | Default | Required |
|------------------------------------------------------------------------------------------------|--------------------------------------|----------|---------|----------|
| <span id="input_resource_group_name"></span> [resource_group_name](#input_resource_group_name) | Name of the resource group to create | `string` | n/a     | yes      |

## Outputs

| Name                                                                                             | Description                                                        |
|--------------------------------------------------------------------------------------------------|--------------------------------------------------------------------|
| <span id="output_resource_group_name"></span> [resource_group_name](#output_resource_group_name) | Name of the resource group created for the Management landing zone |

<!-- END_TF_DOCS -->

## Support

For issues, questions, or contributions related to this module, please
contact the Ensono Stacks team.

## License

Copyright (c) 2025 Ensono

This project is licensed under the MIT License.
