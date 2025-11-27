output "application_gateway_id" {
  description = "ID of the application gateway"
  value       = azurerm_application_gateway.main.id
}

output "application_gateway_name" {
  description = "Name of the application gateway"
  value       = azurerm_application_gateway.main.name
}

output "public_ip_address" {
  description = "Public IP address of the application gateway"
  value       = azurerm_public_ip.appgw.ip_address
}

output "public_ip_id" {
  description = "ID of the public IP"
  value       = azurerm_public_ip.appgw.id
}