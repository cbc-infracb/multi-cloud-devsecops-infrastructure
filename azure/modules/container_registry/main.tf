terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
  }
}

# Azure Container Registry
resource "azurerm_container_registry" "main" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku

  # Security configurations
  admin_enabled                 = false
  public_network_access_enabled = false
  network_rule_bypass_option    = "AzureServices"

  # Enable zone redundancy for Premium SKU
  zone_redundancy_enabled = var.sku == "Premium"

  # Retention policy for untagged manifests (Premium only)
  dynamic "retention_policy" {
    for_each = var.sku == "Premium" ? [1] : []
    content {
      days    = var.retention_days
      enabled = true
    }
  }

  # Trust policy for content trust (Premium only)
  dynamic "trust_policy" {
    for_each = var.sku == "Premium" ? [1] : []
    content {
      enabled = true
    }
  }


  # Enable encryption at rest
  dynamic "encryption" {
    for_each = var.sku == "Premium" ? [1] : []
    content {
      enabled = true
    }
  }

  tags = var.tags
}

# Private Endpoint for secure access
resource "azurerm_private_endpoint" "acr" {
  count = var.private_endpoint_subnet_id != null ? 1 : 0

  name                = "${var.name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.name}-psc"
    private_connection_resource_id = azurerm_container_registry.main.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "acr-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.acr[0].id]
  }

  tags = var.tags
}

# Private DNS Zone for ACR
resource "azurerm_private_dns_zone" "acr" {
  count = var.private_endpoint_subnet_id != null ? 1 : 0

  name                = "privatelink.azurecr.io"
  resource_group_name = var.resource_group_name

  tags = var.tags
}

# Link Private DNS Zone to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "acr" {
  count = var.private_endpoint_subnet_id != null ? 1 : 0

  name                  = "${var.name}-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.acr[0].name
  virtual_network_id    = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.Network/virtualNetworks/${local.vnet_id}"

  tags = var.tags
}

# Get VNet ID from subnet ID
locals {
  vnet_id = var.private_endpoint_subnet_id != null ? regex(".*virtualNetworks/([^/]+)/.*", var.private_endpoint_subnet_id)[0] : null
}