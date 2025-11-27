terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
  }
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "main" {
  name                = "${var.name_prefix}-law"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.log_analytics_sku
  retention_in_days   = var.log_retention_days

  # Enable data collection for security insights
  internet_ingestion_enabled = true
  internet_query_enabled     = true

  tags = var.tags
}

# Application Insights
resource "azurerm_application_insights" "main" {
  count = var.application_insights_enabled ? 1 : 0

  name                = "${var.name_prefix}-ai"
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.main.id
  application_type    = var.application_insights_type

  # Sampling configuration for cost optimization
  sampling_percentage = var.sampling_percentage

  # Disable IP masking for better troubleshooting (adjust based on compliance requirements)
  disable_ip_masking = var.disable_ip_masking

  tags = var.tags
}

# Action Group for alerts
resource "azurerm_monitor_action_group" "main" {
  name                = "${var.name_prefix}-ag"
  resource_group_name = var.resource_group_name
  short_name          = substr("${var.name_prefix}-ag", 0, 12)

  # Email notifications
  dynamic "email_receiver" {
    for_each = var.alert_email_receivers
    content {
      name          = email_receiver.value.name
      email_address = email_receiver.value.email_address
    }
  }

  # Webhook notifications
  dynamic "webhook_receiver" {
    for_each = var.webhook_receivers
    content {
      name        = webhook_receiver.value.name
      service_uri = webhook_receiver.value.service_uri
    }
  }

  tags = var.tags
}

# Metric alerts for critical infrastructure
resource "azurerm_monitor_metric_alert" "cpu_alert" {
  count = var.enable_default_alerts ? 1 : 0

  name                = "${var.name_prefix}-cpu-alert"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_log_analytics_workspace.main.id]
  description         = "Alert when CPU usage is high"
  severity            = 2

  criteria {
    metric_namespace = "Microsoft.OperationalInsights/workspaces"
    metric_name      = "Average_% Processor Time"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }

  tags = var.tags
}

# Data Collection Rule for enhanced monitoring
resource "azurerm_monitor_data_collection_rule" "main" {
  name                = "${var.name_prefix}-dcr"
  resource_group_name = var.resource_group_name
  location            = var.location

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.main.id
      name                  = "destination-log"
    }
  }

  data_flow {
    streams      = ["Microsoft-Perf", "Microsoft-Syslog", "Microsoft-WindowsEvent"]
    destinations = ["destination-log"]
  }

  data_sources {
    performance_counter {
      streams                       = ["Microsoft-Perf"]
      sampling_frequency_in_seconds = 60
      counter_specifiers = [
        "\\Processor Information(_Total)\\% Processor Time",
        "\\Processor Information(_Total)\\% Privileged Time",
        "\\Memory\\% Committed Bytes In Use",
        "\\Memory\\Available Bytes",
        "\\LogicalDisk(_Total)\\% Disk Time",
        "\\LogicalDisk(_Total)\\% Disk Read Time",
        "\\LogicalDisk(_Total)\\% Disk Write Time"
      ]
      name = "datasource-perfcounter"
    }

    syslog {
      facility_names = ["auth", "authpriv", "cron", "daemon", "mark", "kern", "local0"]
      log_levels     = ["Debug", "Info", "Notice", "Warning", "Error", "Critical", "Alert", "Emergency"]
      name           = "datasource-syslog"
      streams        = ["Microsoft-Syslog"]
    }
  }

  tags = var.tags
}

# Workbook for custom dashboards
resource "azurerm_application_insights_workbook" "main" {
  count = var.application_insights_enabled ? 1 : 0

  name                = "${var.name_prefix}-workbook"
  resource_group_name = var.resource_group_name
  location            = var.location
  display_name        = "${var.name_prefix} Infrastructure Dashboard"

  data_json = jsonencode({
    version = "Notebook/1.0"
    items = [
      {
        type = 1
        content = {
          json = "## Infrastructure Monitoring Dashboard\n\nThis dashboard provides key metrics for infrastructure monitoring and alerting."
        }
      }
    ]
    isLocked            = false
    fallbackResourceIds = [azurerm_application_insights.main[0].id]
  })

  tags = var.tags
}