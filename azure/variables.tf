variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "devsecops"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = can(regex("^(dev|staging|prod)$", var.environment))
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "business_unit" {
  description = "Business unit responsible for the resources"
  type        = string
  default     = "Engineering"
}

variable "cost_center" {
  description = "Cost center for billing"
  type        = string
  default     = "1000"
}

variable "owner_email" {
  description = "Email of the resource owner"
  type        = string
  default     = "admin@company.com"
}

# Network Configuration
variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "aks_subnet_cidr" {
  description = "CIDR block for AKS subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_endpoints_subnet_cidr" {
  description = "CIDR block for private endpoints subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "appgw_subnet_cidr" {
  description = "CIDR block for Application Gateway subnet"
  type        = string
  default     = "10.0.3.0/24"
}

# Container Registry Configuration
variable "acr_sku" {
  description = "SKU for Azure Container Registry"
  type        = string
  default     = "Premium"

  validation {
    condition     = can(regex("^(Basic|Standard|Premium)$", var.acr_sku))
    error_message = "ACR SKU must be one of: Basic, Standard, Premium."
  }
}

# AKS Configuration
variable "aks_default_node_pool_vm_size" {
  description = "VM size for default node pool"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "aks_default_node_pool_count" {
  description = "Initial number of nodes in default node pool"
  type        = number
  default     = 3
}

variable "aks_default_node_pool_min_count" {
  description = "Minimum number of nodes in default node pool"
  type        = number
  default     = 1
}

variable "aks_default_node_pool_max_count" {
  description = "Maximum number of nodes in default node pool"
  type        = number
  default     = 10
}

variable "aks_availability_zones" {
  description = "Availability zones for AKS nodes"
  type        = list(string)
  default     = ["1", "2", "3"]
}

# Monitoring Configuration
variable "log_retention_days" {
  description = "Number of days to retain logs"
  type        = number
  default     = 30
}

variable "enable_sentinel" {
  description = "Enable Azure Sentinel"
  type        = bool
  default     = false
}