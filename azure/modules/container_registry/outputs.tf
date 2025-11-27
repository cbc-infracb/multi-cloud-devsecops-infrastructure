output "registry_id" {
  description = "ID of the container registry"
  value       = azurerm_container_registry.main.id
}

output "name" {
  description = "Name of the container registry"
  value       = azurerm_container_registry.main.name
}

output "login_server" {
  description = "Login server URL for the container registry"
  value       = azurerm_container_registry.main.login_server
}

output "admin_username" {
  description = "Admin username for the container registry"
  value       = azurerm_container_registry.main.admin_username
}

output "admin_password" {
  description = "Admin password for the container registry"
  value       = azurerm_container_registry.main.admin_password
  sensitive   = true
}

output "private_endpoint_id" {
  description = "ID of the private endpoint"
  value       = var.private_endpoint_subnet_id != null ? azurerm_private_endpoint.acr[0].id : null
}

output "private_dns_zone_id" {
  description = "ID of the private DNS zone"
  value       = var.private_endpoint_subnet_id != null ? azurerm_private_dns_zone.acr[0].id : null
}