output "acr_login_server" {
  description = "The login server URL for Azure Container Registry"
  value       = data.azurerm_container_registry.acr.login_server
}

output "aks_cluster_name" {
  description = "Name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "kubeconfig" {
  description = "Raw kubeconfig for the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

output "postgres_host" {
  description = "PostgreSQL server fully-qualified hostname"
  value       = azurerm_postgresql_flexible_server.postgres.fqdn
}

output "database_url" {
  description = "Full DATABASE_URL connection string (append ?sslmode=require for cloud use)"
  value       = "postgresql://${var.postgres_admin_user}:${var.postgres_admin_password}@${azurerm_postgresql_flexible_server.postgres.fqdn}:5432/${var.postgres_db_name}?sslmode=require"
  sensitive   = true
}
