variable "name" {
  description = "Name of the key vault"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.name)) && length(var.name) >= 3 && length(var.name) <= 24
    error_message = "Key vault name must be alphanumeric with hyphens, between 3 and 24 characters."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "sku_name" {
  description = "SKU name for the key vault"
  type        = string
  default     = "premium"

  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "SKU name must be either 'standard' or 'premium'."
  }
}

variable "enabled_for_disk_encryption" {
  description = "Enable key vault for disk encryption"
  type        = bool
  default     = true
}

variable "enabled_for_deployment" {
  description = "Enable key vault for VM deployment"
  type        = bool
  default     = true
}

variable "enabled_for_template_deployment" {
  description = "Enable key vault for ARM template deployment"
  type        = bool
  default     = true
}

variable "purge_protection_enabled" {
  description = "Enable purge protection"
  type        = bool
  default     = true
}

variable "soft_delete_retention_days" {
  description = "Number of days to retain deleted items"
  type        = number
  default     = 30

  validation {
    condition     = var.soft_delete_retention_days >= 7 && var.soft_delete_retention_days <= 90
    error_message = "Soft delete retention days must be between 7 and 90."
  }
}

variable "network_acls" {
  description = "Network access control list configuration"
  type = object({
    bypass                     = string
    default_action             = string
    ip_rules                   = optional(list(string))
    virtual_network_subnet_ids = optional(list(string))
  })
  default = null
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID for the private endpoint"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}