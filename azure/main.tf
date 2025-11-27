terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# Generate random suffix for globally unique names
resource "random_id" "suffix" {
  byte_length = 4
}

locals {
  common_tags = {
    Environment     = var.environment
    Project         = var.project_name
    ManagedBy       = "Terraform"
    BusinessUnit    = var.business_unit
    CostCenter      = var.cost_center
    Owner           = var.owner_email
    CreatedDate     = formatdate("YYYY-MM-DD", timestamp())
    WellArchitected = "true"
  }

  resource_prefix = "${var.project_name}-${var.environment}"
  random_suffix   = lower(random_id.suffix.hex)
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "${local.resource_prefix}-rg"
  location = var.location
  tags     = local.common_tags
}

# Network Security Group with minimal required rules
resource "azurerm_network_security_group" "main" {
  name                = "${local.resource_prefix}-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.common_tags
}

# Virtual Network Module
module "network" {
  source = "./modules/network"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  vnet_name           = "${local.resource_prefix}-vnet"
  address_space       = var.vnet_address_space

  subnets = {
    aks = {
      name             = "aks-subnet"
      address_prefixes = [var.aks_subnet_cidr]
    }
    private_endpoints = {
      name             = "private-endpoints-subnet"
      address_prefixes = [var.private_endpoints_subnet_cidr]
    }
    application_gateway = {
      name             = "appgw-subnet"
      address_prefixes = [var.appgw_subnet_cidr]
    }
  }

  network_security_group_id = azurerm_network_security_group.main.id
  tags                      = local.common_tags
}

# Azure Container Registry Module
module "container_registry" {
  source = "./modules/container_registry"

  name                = "${replace(local.resource_prefix, "-", "")}acr${local.random_suffix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = var.acr_sku

  # Enable private endpoint for security
  private_endpoint_subnet_id = module.network.subnet_ids["private_endpoints"]

  tags = local.common_tags
}

# Key Vault Module
module "key_vault" {
  source = "./modules/key_vault"

  name                = "${local.resource_prefix}-kv-${local.random_suffix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  # Security configurations
  enabled_for_disk_encryption     = true
  enabled_for_deployment          = true
  enabled_for_template_deployment = true
  purge_protection_enabled        = var.environment == "production"

  # Network access restrictions
  network_acls = {
    bypass         = "AzureServices"
    default_action = "Deny"
    virtual_network_subnet_ids = [
      module.network.subnet_ids["aks"],
      module.network.subnet_ids["private_endpoints"]
    ]
  }

  # Private endpoint for secure access
  private_endpoint_subnet_id = module.network.subnet_ids["private_endpoints"]

  tags = local.common_tags
}

# AKS Cluster Module
module "aks" {
  source = "./modules/aks"

  cluster_name        = "${local.resource_prefix}-aks"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  # Network configuration
  vnet_subnet_id = module.network.subnet_ids["aks"]

  # Node pool configuration
  default_node_pool = {
    name                = "default"
    vm_size             = var.aks_default_node_pool_vm_size
    node_count          = var.aks_default_node_pool_count
    zones               = var.aks_availability_zones
    enable_auto_scaling = true
    min_count           = var.aks_default_node_pool_min_count
    max_count           = var.aks_default_node_pool_max_count
  }

  # Security configurations
  private_cluster_enabled           = true
  role_based_access_control_enabled = true
  azure_policy_enabled              = true

  # Container insights for monitoring
  oms_agent_enabled          = true
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id

  # Integration with ACR
  container_registry_id = module.container_registry.registry_id

  tags = local.common_tags
}

# Application Gateway Module
module "application_gateway" {
  source = "./modules/application_gateway"

  name                = "${local.resource_prefix}-appgw"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  subnet_id = module.network.subnet_ids["application_gateway"]

  # WAF configuration for security
  waf_enabled = true
  waf_configuration = {
    enabled          = true
    firewall_mode    = "Prevention"
    rule_set_type    = "OWASP"
    rule_set_version = "3.2"
  }

  tags = local.common_tags
}

# Monitoring and Logging Module
module "monitoring" {
  source = "./modules/monitoring"

  name_prefix         = local.resource_prefix
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  # Log Analytics configuration
  log_retention_days = var.log_retention_days

  # Application Insights for application monitoring
  application_insights_enabled = true

  tags = local.common_tags
}

# Security Module (Defender, Sentinel)
module "security" {
  source = "./modules/security"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id

  # Enable Microsoft Defender for containers
  defender_for_containers_enabled = true

  # Enable Azure Sentinel
  sentinel_enabled = var.enable_sentinel

  tags = local.common_tags
}