variable "resource_group_name" {
  description = "Name of the Azure resource group"
  type        = string
}

variable "location" {
  description = "Azure region to deploy resources"
  type        = string
  default     = "eastus2"
}

variable "acr_name" {
  description = "Name of the Azure Container Registry (must be globally unique, alphanumeric only)"
  type        = string
}

variable "acr_resource_group_name" {
  description = "Resource group where the existing ACR lives (may differ from the main resource group)"
  type        = string
}

variable "aks_cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
  default     = "journal-aks"
}

variable "aks_node_count" {
  description = "Number of nodes in the AKS default node pool"
  type        = number
  default     = 2
}

variable "aks_node_vm_size" {
  description = "VM size for AKS nodes"
  type        = string
  default     = "Standard_B2s"
}

variable "postgres_server_name" {
  description = "Name of the PostgreSQL Flexible Server (must be globally unique)"
  type        = string
}

variable "postgres_admin_user" {
  description = "PostgreSQL administrator username"
  type        = string
  default     = "postgres"
}

variable "postgres_admin_password" {
  description = "PostgreSQL administrator password"
  type        = string
  sensitive   = true
}

variable "postgres_db_name" {
  description = "Name of the database to create"
  type        = string
  default     = "career_journal"
}
