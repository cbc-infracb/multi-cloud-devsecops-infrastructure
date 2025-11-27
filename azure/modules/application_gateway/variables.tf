variable "name" {
  description = "Name of the application gateway"
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

variable "subnet_id" {
  description = "Subnet ID for the application gateway"
  type        = string
}

variable "sku_name" {
  description = "SKU name for the application gateway"
  type        = string
  default     = "WAF_v2"

  validation {
    condition     = contains(["Standard_Small", "Standard_Medium", "Standard_Large", "Standard_v2", "WAF_Medium", "WAF_Large", "WAF_v2"], var.sku_name)
    error_message = "SKU name must be a valid Application Gateway SKU."
  }
}

variable "sku_tier" {
  description = "SKU tier for the application gateway"
  type        = string
  default     = "WAF_v2"

  validation {
    condition     = contains(["Standard", "Standard_v2", "WAF", "WAF_v2"], var.sku_tier)
    error_message = "SKU tier must be a valid Application Gateway tier."
  }
}

variable "sku_capacity" {
  description = "SKU capacity for the application gateway"
  type        = number
  default     = 2

  validation {
    condition     = var.sku_capacity >= 1 && var.sku_capacity <= 125
    error_message = "SKU capacity must be between 1 and 125."
  }
}

variable "enable_autoscaling" {
  description = "Enable autoscaling for the application gateway"
  type        = bool
  default     = true
}

variable "autoscale_min_capacity" {
  description = "Minimum capacity for autoscaling"
  type        = number
  default     = 2
}

variable "autoscale_max_capacity" {
  description = "Maximum capacity for autoscaling"
  type        = number
  default     = 10
}

variable "waf_enabled" {
  description = "Enable WAF"
  type        = bool
  default     = true
}

variable "waf_configuration" {
  description = "WAF configuration"
  type = object({
    enabled          = bool
    firewall_mode    = string
    rule_set_type    = string
    rule_set_version = string
  })
  default = {
    enabled          = true
    firewall_mode    = "Prevention"
    rule_set_type    = "OWASP"
    rule_set_version = "3.2"
  }
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for diagnostics"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}