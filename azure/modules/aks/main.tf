terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
  }
}

# AKS Cluster
resource "azurerm_kubernetes_cluster" "main" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "${var.cluster_name}-dns"
  kubernetes_version  = var.kubernetes_version

  # Private cluster configuration for security
  private_cluster_enabled             = var.private_cluster_enabled
  private_dns_zone_id                 = var.private_cluster_enabled ? "System" : null
  private_cluster_public_fqdn_enabled = false

  # Security configurations
  role_based_access_control_enabled = var.role_based_access_control_enabled
  azure_policy_enabled              = var.azure_policy_enabled
  local_account_disabled            = true

  # Default node pool
  default_node_pool {
    name                         = var.default_node_pool.name
    node_count                   = var.default_node_pool.enable_auto_scaling ? null : var.default_node_pool.node_count
    vm_size                      = var.default_node_pool.vm_size
    zones                        = var.default_node_pool.zones
    enable_auto_scaling          = var.default_node_pool.enable_auto_scaling
    min_count                    = var.default_node_pool.enable_auto_scaling ? var.default_node_pool.min_count : null
    max_count                    = var.default_node_pool.enable_auto_scaling ? var.default_node_pool.max_count : null
    max_pods                     = var.default_node_pool.max_pods
    os_disk_size_gb              = var.default_node_pool.os_disk_size_gb
    os_disk_type                 = var.default_node_pool.os_disk_type
    vnet_subnet_id               = var.vnet_subnet_id
    enable_node_public_ip        = false
    only_critical_addons_enabled = true

    upgrade_settings {
      max_surge = "10%"
    }

    tags = var.tags
  }

  # System-assigned managed identity
  identity {
    type = "SystemAssigned"
  }

  # Network profile
  network_profile {
    network_plugin    = var.network_plugin
    network_policy    = var.network_policy
    dns_service_ip    = var.dns_service_ip
    service_cidr      = var.service_cidr
    outbound_type     = "loadBalancer"
    load_balancer_sku = "standard"
  }

  # Azure AD integration
  dynamic "azure_active_directory_role_based_access_control" {
    for_each = var.azure_ad_integration ? [1] : []
    content {
      managed                = true
      tenant_id              = var.tenant_id
      admin_group_object_ids = var.admin_group_object_ids
      azure_rbac_enabled     = true
    }
  }

  # Container insights (monitoring)
  dynamic "oms_agent" {
    for_each = var.oms_agent_enabled ? [1] : []
    content {
      log_analytics_workspace_id      = var.log_analytics_workspace_id
      msi_auth_for_monitoring_enabled = true
    }
  }

  # Auto-scaler profile for cost optimization
  auto_scaler_profile {
    balance_similar_node_groups      = true
    expander                         = "random"
    max_graceful_termination_sec     = 600
    max_node_provisioning_time       = "15m"
    max_unready_nodes                = 3
    max_unready_percentage           = 45
    new_pod_scale_up_delay           = "10s"
    scale_down_delay_after_add       = "10m"
    scale_down_delay_after_delete    = "10s"
    scale_down_delay_after_failure   = "3m"
    scan_interval                    = "10s"
    scale_down_unneeded              = "10m"
    scale_down_unready               = "20m"
    scale_down_utilization_threshold = 0.5
    empty_bulk_delete_max            = 10
    skip_nodes_with_local_storage    = true
    skip_nodes_with_system_pods      = true
  }

  # Maintenance window for updates
  maintenance_window {
    allowed {
      day   = "Saturday"
      hours = [2, 3, 4]
    }
    allowed {
      day   = "Sunday"
      hours = [2, 3, 4]
    }
  }

  tags = var.tags

}

# System node pool for system workloads
resource "azurerm_kubernetes_cluster_node_pool" "system" {
  count = var.create_system_node_pool ? 1 : 0

  name                  = "system"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = var.system_node_pool.vm_size
  node_count            = var.system_node_pool.node_count
  zones                 = var.system_node_pool.zones
  mode                  = "System"
  os_disk_size_gb       = var.system_node_pool.os_disk_size_gb
  os_disk_type          = var.system_node_pool.os_disk_type
  vnet_subnet_id        = var.vnet_subnet_id
  enable_auto_scaling   = var.system_node_pool.enable_auto_scaling
  min_count             = var.system_node_pool.enable_auto_scaling ? var.system_node_pool.min_count : null
  max_count             = var.system_node_pool.enable_auto_scaling ? var.system_node_pool.max_count : null

  node_taints = ["CriticalAddonsOnly=true:NoSchedule"]

  upgrade_settings {
    max_surge = "10%"
  }

  tags = var.tags
}

# Role assignment for ACR integration
resource "azurerm_role_assignment" "acr_pull" {
  count = var.container_registry_id != null ? 1 : 0

  scope                = var.container_registry_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
}

# Role assignment for network contributor (required for custom VNet)
resource "azurerm_role_assignment" "network_contributor" {
  scope                = var.vnet_subnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.main.identity[0].principal_id
}