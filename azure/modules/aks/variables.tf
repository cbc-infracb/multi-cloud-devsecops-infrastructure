variable "cluster_name" {
  description = "Name of the AKS cluster"
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

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = null
}

variable "vnet_subnet_id" {
  description = "Subnet ID for the AKS cluster"
  type        = string
}

variable "private_cluster_enabled" {
  description = "Enable private cluster"
  type        = bool
  default     = true
}

variable "role_based_access_control_enabled" {
  description = "Enable RBAC"
  type        = bool
  default     = true
}

variable "azure_policy_enabled" {
  description = "Enable Azure Policy addon"
  type        = bool
  default     = true
}

variable "default_node_pool" {
  description = "Default node pool configuration"
  type = object({
    name                = string
    vm_size             = string
    node_count          = optional(number, 3)
    zones               = optional(list(string), ["1", "2", "3"])
    enable_auto_scaling = optional(bool, true)
    min_count           = optional(number, 1)
    max_count           = optional(number, 10)
    max_pods            = optional(number, 110)
    os_disk_size_gb     = optional(number, 128)
    os_disk_type        = optional(string, "Managed")
  })
}

variable "create_system_node_pool" {
  description = "Create a separate system node pool"
  type        = bool
  default     = false
}

variable "system_node_pool" {
  description = "System node pool configuration"
  type = object({
    vm_size             = optional(string, "Standard_D2s_v3")
    node_count          = optional(number, 2)
    zones               = optional(list(string), ["1", "2", "3"])
    enable_auto_scaling = optional(bool, true)
    min_count           = optional(number, 1)
    max_count           = optional(number, 3)
    os_disk_size_gb     = optional(number, 128)
    os_disk_type        = optional(string, "Managed")
  })
  default = {}
}

variable "network_plugin" {
  description = "Network plugin for AKS"
  type        = string
  default     = "azure"

  validation {
    condition     = contains(["azure", "kubenet"], var.network_plugin)
    error_message = "Network plugin must be 'azure' or 'kubenet'."
  }
}

variable "network_policy" {
  description = "Network policy for AKS"
  type        = string
  default     = "azure"

  validation {
    condition     = contains(["azure", "calico"], var.network_policy)
    error_message = "Network policy must be 'azure' or 'calico'."
  }
}

variable "dns_service_ip" {
  description = "DNS service IP for AKS"
  type        = string
  default     = "10.100.0.10"
}

variable "service_cidr" {
  description = "Service CIDR for AKS"
  type        = string
  default     = "10.100.0.0/16"
}

variable "azure_ad_integration" {
  description = "Enable Azure AD integration"
  type        = bool
  default     = true
}

variable "tenant_id" {
  description = "Azure AD tenant ID"
  type        = string
  default     = null
}

variable "admin_group_object_ids" {
  description = "Azure AD admin group object IDs"
  type        = list(string)
  default     = []
}

variable "oms_agent_enabled" {
  description = "Enable OMS agent for monitoring"
  type        = bool
  default     = true
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID"
  type        = string
  default     = null
}

variable "container_registry_id" {
  description = "Container registry ID for ACR integration"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}