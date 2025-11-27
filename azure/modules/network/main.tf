terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
  }
}

# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space

  tags = var.tags
}

# Subnets
resource "azurerm_subnet" "subnets" {
  for_each = var.subnets

  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = each.value.address_prefixes

  # Enable private endpoint network policies for private endpoints subnet
  private_endpoint_network_policies_enabled = each.key == "private_endpoints" ? false : true
}

# Network Security Group Association
resource "azurerm_subnet_network_security_group_association" "main" {
  for_each = var.subnets

  subnet_id                 = azurerm_subnet.subnets[each.key].id
  network_security_group_id = var.network_security_group_id
}

# Route Table for enhanced security
resource "azurerm_route_table" "main" {
  name                = "${var.vnet_name}-rt"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Disable BGP route propagation for security
  disable_bgp_route_propagation = true

  tags = var.tags
}

# Route Table Association
resource "azurerm_subnet_route_table_association" "main" {
  for_each = var.subnets

  subnet_id      = azurerm_subnet.subnets[each.key].id
  route_table_id = azurerm_route_table.main.id
}