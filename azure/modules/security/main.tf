terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
  }
}

# Microsoft Defender for Cloud Security Contacts
resource "azurerm_security_center_contact" "main" {
  count = length(var.security_contact_emails) > 0 ? 1 : 0

  email               = var.security_contact_emails[0]
  phone               = var.security_contact_phone
  alert_notifications = true
  alerts_to_admins    = true
}

# Security Center Subscription Pricing (Defender for Cloud)
resource "azurerm_security_center_subscription_pricing" "defender_for_containers" {
  count = var.defender_for_containers_enabled ? 1 : 0

  tier          = "Standard"
  resource_type = "Containers"
}

resource "azurerm_security_center_subscription_pricing" "defender_for_keyvault" {
  count = var.defender_for_keyvault_enabled ? 1 : 0

  tier          = "Standard"
  resource_type = "KeyVaults"
}

resource "azurerm_security_center_subscription_pricing" "defender_for_storage" {
  count = var.defender_for_storage_enabled ? 1 : 0

  tier          = "Standard"
  resource_type = "StorageAccounts"
}

# Azure Sentinel (if enabled)
resource "azurerm_sentinel_log_analytics_workspace_onboarding" "main" {
  count = var.sentinel_enabled ? 1 : 0

  workspace_id                 = var.log_analytics_workspace_id
  customer_managed_key_enabled = var.sentinel_customer_managed_key_enabled
}

# Sentinel Data Connectors
resource "azurerm_sentinel_data_connector_azure_active_directory" "main" {
  count = var.sentinel_enabled ? 1 : 0

  name                       = "azure-active-directory"
  log_analytics_workspace_id = var.log_analytics_workspace_id
  tenant_id                  = data.azurerm_client_config.current.tenant_id

  depends_on = [azurerm_sentinel_log_analytics_workspace_onboarding.main]
}

resource "azurerm_sentinel_data_connector_azure_security_center" "main" {
  count = var.sentinel_enabled ? 1 : 0

  name                       = "azure-security-center"
  log_analytics_workspace_id = var.log_analytics_workspace_id
  subscription_id            = data.azurerm_client_config.current.subscription_id

  depends_on = [azurerm_sentinel_log_analytics_workspace_onboarding.main]
}

resource "azurerm_sentinel_data_connector_microsoft_cloud_app_security" "main" {
  count = var.sentinel_enabled && var.enable_mcas_connector ? 1 : 0

  name                       = "microsoft-cloud-app-security"
  log_analytics_workspace_id = var.log_analytics_workspace_id
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  alerts_enabled             = true
  discovery_logs_enabled     = true

  depends_on = [azurerm_sentinel_log_analytics_workspace_onboarding.main]
}

# Sentinel Analytics Rules
resource "azurerm_sentinel_alert_rule_scheduled" "suspicious_login" {
  count = var.sentinel_enabled ? 1 : 0

  name                       = "Suspicious Login Activity"
  log_analytics_workspace_id = var.log_analytics_workspace_id
  display_name               = "Suspicious Login Activity"
  severity                   = "High"
  query                      = <<QUERY
SigninLogs
| where TimeGenerated > ago(1h)
| where RiskLevelDuringSignIn == "high" or RiskLevelAggregated == "high"
| project TimeGenerated, UserPrincipalName, IPAddress, Location, RiskLevelDuringSignIn, RiskLevelAggregated
QUERY

  query_frequency   = "PT1H"
  query_period      = "PT1H"
  trigger_operator  = "GreaterThan"
  trigger_threshold = 0

  tactics = ["InitialAccess"]

  depends_on = [azurerm_sentinel_log_analytics_workspace_onboarding.main]
}

resource "azurerm_sentinel_alert_rule_scheduled" "failed_logins" {
  count = var.sentinel_enabled ? 1 : 0

  name                       = "Multiple Failed Login Attempts"
  log_analytics_workspace_id = var.log_analytics_workspace_id
  display_name               = "Multiple Failed Login Attempts"
  severity                   = "Medium"
  query                      = <<QUERY
SigninLogs
| where TimeGenerated > ago(1h)
| where ResultType != "0"
| summarize FailedAttempts = count() by UserPrincipalName, IPAddress
| where FailedAttempts >= 5
QUERY

  query_frequency   = "PT1H"
  query_period      = "PT1H"
  trigger_operator  = "GreaterThan"
  trigger_threshold = 0

  tactics = ["CredentialAccess"]

  depends_on = [azurerm_sentinel_log_analytics_workspace_onboarding.main]
}

# Sentinel Watchlist for known bad IPs
resource "azurerm_sentinel_watchlist" "bad_ips" {
  count = var.sentinel_enabled ? 1 : 0

  name                       = "BadIPs"
  log_analytics_workspace_id = var.log_analytics_workspace_id
  display_name               = "Known Bad IP Addresses"
  description                = "List of known malicious IP addresses"
  labels                     = ["IP", "ThreatIntel"]
  default_duration           = "P30D"
  item_search_key            = "IPAddress"

  depends_on = [azurerm_sentinel_log_analytics_workspace_onboarding.main]
}

# Data source for current client config
data "azurerm_client_config" "current" {}