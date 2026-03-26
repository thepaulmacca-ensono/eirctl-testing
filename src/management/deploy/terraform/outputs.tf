output "resource_group_name" {
  value       = azurerm_resource_group.management.name
  description = "Name of the resource group created for the Management landing zone"
}
