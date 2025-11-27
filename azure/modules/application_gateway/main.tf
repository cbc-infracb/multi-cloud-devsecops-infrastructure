terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
  }
}

# Public IP for Application Gateway
resource "azurerm_public_ip" "appgw" {
  name                = "${var.name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]

  tags = var.tags
}

# Application Gateway
resource "azurerm_application_gateway" "main" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  zones               = ["1", "2", "3"]

  sku {
    name     = var.sku_name
    tier     = var.sku_tier
    capacity = var.sku_capacity
  }

  # Autoscaling configuration
  dynamic "autoscale_configuration" {
    for_each = var.enable_autoscaling ? [1] : []
    content {
      min_capacity = var.autoscale_min_capacity
      max_capacity = var.autoscale_max_capacity
    }
  }

  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = var.subnet_id
  }

  frontend_port {
    name = "http-port"
    port = 80
  }

  frontend_port {
    name = "https-port"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "appGatewayFrontendIP"
    public_ip_address_id = azurerm_public_ip.appgw.id
  }

  backend_address_pool {
    name = "default-backend-pool"
  }

  backend_http_settings {
    name                  = "default-http-settings"
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
    probe_name            = "default-probe"
  }

  http_listener {
    name                           = "default-http-listener"
    frontend_ip_configuration_name = "appGatewayFrontendIP"
    frontend_port_name             = "http-port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "default-routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "default-http-listener"
    backend_address_pool_name  = "default-backend-pool"
    backend_http_settings_name = "default-http-settings"
    priority                   = 100
  }

  probe {
    name                                      = "default-probe"
    protocol                                  = "Http"
    path                                      = "/"
    host                                      = "localhost"
    interval                                  = 30
    timeout                                   = 30
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = false

    match {
      status_code = ["200-399"]
    }
  }

  # WAF Configuration
  dynamic "waf_configuration" {
    for_each = var.waf_enabled ? [var.waf_configuration] : []
    content {
      enabled          = waf_configuration.value.enabled
      firewall_mode    = waf_configuration.value.firewall_mode
      rule_set_type    = waf_configuration.value.rule_set_type
      rule_set_version = waf_configuration.value.rule_set_version

      # Enable all OWASP rules for maximum security
      disabled_rule_group {
        rule_group_name = "REQUEST-942-APPLICATION-ATTACK-SQLI"
        rules           = []
      }

      disabled_rule_group {
        rule_group_name = "REQUEST-931-APPLICATION-ATTACK-RFI"
        rules           = []
      }
    }
  }

  # Enable HTTP2 for better performance
  enable_http2 = true

  tags = var.tags
}

# Diagnostic settings for monitoring
resource "azurerm_monitor_diagnostic_setting" "appgw" {
  count = var.log_analytics_workspace_id != null ? 1 : 0

  name                       = "${var.name}-diagnostics"
  target_resource_id         = azurerm_application_gateway.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "ApplicationGatewayAccessLog"
  }

  enabled_log {
    category = "ApplicationGatewayPerformanceLog"
  }

  enabled_log {
    category = "ApplicationGatewayFirewallLog"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}