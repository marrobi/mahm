variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
  default     = "rg-mahm-dev"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "UK South"
}

variable "resource_prefix" {
  description = "Prefix for all resource names"
  type        = string
  default     = "mahm-dev"
}

variable "ai_foundry_workspace_name" {
  description = "Name of the Azure AI Foundry workspace"
  type        = string
  default     = "mahm-ai-foundry-dev"
}

variable "storage_account_name" {
  description = "Name of the storage account for AI Foundry"
  type        = string
  default     = "mahmaidevst001"
  
  validation {
    condition     = length(var.storage_account_name) >= 3 && length(var.storage_account_name) <= 24 && can(regex("^[a-z0-9]+$", var.storage_account_name))
    error_message = "Storage account name must be between 3 and 24 characters long and can contain only lowercase letters and numbers."
  }
}

variable "application_insights_name" {
  description = "Name of the Application Insights instance"
  type        = string
  default     = "mahm-ai-insights-dev"
}

variable "key_vault_name" {
  description = "Name of the Azure Key Vault"
  type        = string
  default     = "mahm-kv-dev-001"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "mahm"
}

variable "cost_center" {
  description = "Cost center for billing"
  type        = string
  default     = "demo"
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = "mahm-team"
}