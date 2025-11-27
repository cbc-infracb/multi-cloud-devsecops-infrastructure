output "cluster_id" {
  description = "ID of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.id
}

output "cluster_name" {
  description = "Name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.name
}

output "fqdn" {
  description = "FQDN of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.fqdn
}

output "private_fqdn" {
  description = "Private FQDN of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.private_fqdn
}

output "kube_config" {
  description = "Kubeconfig for the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.kube_config
  sensitive   = true
}

output "kube_config_raw" {
  description = "Raw kubeconfig for the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive   = true
}

output "kubelet_identity" {
  description = "Kubelet managed identity"
  value       = azurerm_kubernetes_cluster.main.kubelet_identity
}

output "cluster_identity" {
  description = "Cluster managed identity"
  value       = azurerm_kubernetes_cluster.main.identity
}

output "oidc_issuer_url" {
  description = "OIDC issuer URL"
  value       = azurerm_kubernetes_cluster.main.oidc_issuer_url
}

output "node_resource_group" {
  description = "Resource group containing AKS cluster nodes"
  value       = azurerm_kubernetes_cluster.main.node_resource_group
}