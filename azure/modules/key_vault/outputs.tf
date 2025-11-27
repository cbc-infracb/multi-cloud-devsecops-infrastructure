output "key_vault_id" {
  description = "ID of the key vault"
  value       = azurerm_key_vault.main.id
}

output "name" {
  description = "Name of the key vault"
  value       = azurerm_key_vault.main.name
}

output "vault_uri" {
  description = "URI of the key vault"
  value       = azurerm_key_vault.main.vault_uri
}

output "tenant_id" {
  description = "Tenant ID associated with the key vault"
  value       = azurerm_key_vault.main.tenant_id
}

output "private_endpoint_id" {
  description = "ID of the private endpoint"
  value       = var.private_endpoint_subnet_id != null ? azurerm_private_endpoint.kv[0].id : null
}

output "private_dns_zone_id" {
  description = "ID of the private DNS zone"
  value       = var.private_endpoint_subnet_id != null ? azurerm_private_dns_zone.kv[0].id : null
}