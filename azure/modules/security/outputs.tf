output "security_center_contact_id" {
  description = "ID of the security center contact"
  value       = length(var.security_contact_emails) > 0 ? azurerm_security_center_contact.main[0].id : null
}

output "sentinel_workspace_onboarding_id" {
  description = "ID of the Sentinel workspace onboarding"
  value       = var.sentinel_enabled ? azurerm_sentinel_log_analytics_workspace_onboarding.main[0].id : null
}

output "defender_for_containers_id" {
  description = "ID of Defender for Containers pricing"
  value       = var.defender_for_containers_enabled ? azurerm_security_center_subscription_pricing.defender_for_containers[0].id : null
}

output "defender_for_keyvault_id" {
  description = "ID of Defender for Key Vault pricing"
  value       = var.defender_for_keyvault_enabled ? azurerm_security_center_subscription_pricing.defender_for_keyvault[0].id : null
}

output "defender_for_storage_id" {
  description = "ID of Defender for Storage pricing"
  value       = var.defender_for_storage_enabled ? azurerm_security_center_subscription_pricing.defender_for_storage[0].id : null
}