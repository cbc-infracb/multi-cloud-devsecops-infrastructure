variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  type        = string
}

variable "security_contact_emails" {
  description = "List of email addresses for security contacts"
  type        = list(string)
  default     = []
}

variable "security_contact_phone" {
  description = "Phone number for security contacts"
  type        = string
  default     = ""
}

variable "defender_for_containers_enabled" {
  description = "Enable Microsoft Defender for Containers"
  type        = bool
  default     = true
}

variable "defender_for_keyvault_enabled" {
  description = "Enable Microsoft Defender for Key Vault"
  type        = bool
  default     = true
}

variable "defender_for_storage_enabled" {
  description = "Enable Microsoft Defender for Storage"
  type        = bool
  default     = true
}

variable "sentinel_enabled" {
  description = "Enable Azure Sentinel"
  type        = bool
  default     = false
}

variable "sentinel_customer_managed_key_enabled" {
  description = "Enable customer managed keys for Sentinel"
  type        = bool
  default     = false
}

variable "enable_mcas_connector" {
  description = "Enable Microsoft Cloud App Security connector"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}