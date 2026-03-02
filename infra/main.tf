# Resource Group
resource "azurerm_resource_group" "capstone" {
  name     = var.resource_group_name
  location = var.location
}

# ─── Azure Container Registry (already exists, referenced as data source) ────
data "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = var.acr_resource_group_name
}

# ─── AKS Cluster ────────────────────────────────────────────────────────────
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.capstone.location
  resource_group_name = azurerm_resource_group.capstone.name
  dns_prefix          = var.aks_cluster_name

  default_node_pool {
    name       = "default"
    node_count = var.aks_node_count
    vm_size    = var.aks_node_vm_size
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    project = "journal-api"
  }
}

# ─── IAM: Allow AKS to pull from ACR ────────────────────────────────────────
resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = data.azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}

# ─── PostgreSQL Flexible Server ─────────────────────────────────────────────
resource "azurerm_postgresql_flexible_server" "postgres" {
  name                   = var.postgres_server_name
  resource_group_name    = azurerm_resource_group.capstone.name
  location               = azurerm_resource_group.capstone.location
  version                = "15"
  administrator_login    = var.postgres_admin_user
  administrator_password = var.postgres_admin_password
  sku_name               = "B_Standard_B1ms"
  storage_mb             = 32768

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false

  tags = {
    project = "journal-api"
  }
}

# Allow all Azure services to reach the PostgreSQL server
resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_azure" {
  name             = "allow-azure-services"
  server_id        = azurerm_postgresql_flexible_server.postgres.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# Create the application database
resource "azurerm_postgresql_flexible_server_database" "db" {
  name      = var.postgres_db_name
  server_id = azurerm_postgresql_flexible_server.postgres.id
  collation = "en_US.utf8"
  charset   = "utf8"
}
