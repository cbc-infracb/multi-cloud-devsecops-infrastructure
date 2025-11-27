variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "log_analytics_sku" {
  description = "SKU for Log Analytics workspace"
  type        = string
  default     = "PerGB2018"

  validation {
    condition     = contains(["Free", "Standalone", "PerNode", "PerGB2018"], var.log_analytics_sku)
    error_message = "Log Analytics SKU must be one of: Free, Standalone, PerNode, PerGB2018."
  }
}

variable "log_retention_days" {
  description = "Number of days to retain logs"
  type        = number
  default     = 30

  validation {
    condition     = var.log_retention_days >= 30 && var.log_retention_days <= 730
    error_message = "Log retention days must be between 30 and 730."
  }
}

variable "application_insights_enabled" {
  description = "Enable Application Insights"
  type        = bool
  default     = true
}

variable "application_insights_type" {
  description = "Application Insights application type"
  type        = string
  default     = "web"

  validation {
    condition     = contains(["ios", "java", "MobileCenter", "Node.JS", "other", "phone", "store", "web"], var.application_insights_type)
    error_message = "Application Insights type must be one of the supported types."
  }
}

variable "sampling_percentage" {
  description = "Sampling percentage for Application Insights"
  type        = number
  default     = 100

  validation {
    condition     = var.sampling_percentage > 0 && var.sampling_percentage <= 100
    error_message = "Sampling percentage must be between 0 and 100."
  }
}

variable "disable_ip_masking" {
  description = "Disable IP masking in Application Insights"
  type        = bool
  default     = false
}

variable "alert_email_receivers" {
  description = "List of email receivers for alerts"
  type = list(object({
    name          = string
    email_address = string
  }))
  default = []
}

variable "webhook_receivers" {
  description = "List of webhook receivers for alerts"
  type = list(object({
    name        = string
    service_uri = string
  }))
  default = []
}

variable "enable_default_alerts" {
  description = "Enable default metric alerts"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}