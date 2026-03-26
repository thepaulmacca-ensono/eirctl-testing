output "resource_group_name" {
  value       = azurerm_resource_group.identity.name
  description = "Name of the resource group created for the Identity landing zone"
}
