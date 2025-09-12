terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

# Data sources for current context
data "azurerm_client_config" "current" {}

# Resource Group
resource "azurerm_resource_group" "mahm" {
  name     = var.resource_group_name
  location = var.location

  tags = local.common_tags
}

# Storage Account for AI Foundry workspace (required dependency)
resource "azurerm_storage_account" "mahm" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.mahm.name
  location                 = azurerm_resource_group.mahm.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  # Security configurations
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = true

  tags = local.common_tags
}

# Application Insights for AI Foundry observability (required dependency)
resource "azurerm_application_insights" "mahm" {
  name                = var.application_insights_name
  location            = azurerm_resource_group.mahm.location
  resource_group_name = azurerm_resource_group.mahm.name
  application_type    = "web"

  tags = local.common_tags
}

# Key Vault for AI Foundry secure storage (required dependency)
resource "azurerm_key_vault" "mahm" {
  name                = var.key_vault_name
  location            = azurerm_resource_group.mahm.location
  resource_group_name = azurerm_resource_group.mahm.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  # Enable soft delete and purge protection
  soft_delete_retention_days = 7
  purge_protection_enabled   = false # Set to true for production

  # Access policies for deployment user
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get", "List", "Create", "Delete", "Update", "Recover"
    ]

    secret_permissions = [
      "Get", "List", "Set", "Delete", "Recover"
    ]

    certificate_permissions = [
      "Get", "List", "Create", "Delete", "Update", "Import"
    ]
  }

  tags = local.common_tags
}

# Azure AI Foundry Workspace (Azure Machine Learning Workspace for AI Foundry)
resource "azurerm_machine_learning_workspace" "ai_foundry" {
  name                = var.ai_foundry_workspace_name
  location            = azurerm_resource_group.mahm.location
  resource_group_name = azurerm_resource_group.mahm.name

  # Required dependencies for AI Foundry
  application_insights_id = azurerm_application_insights.mahm.id
  key_vault_id           = azurerm_key_vault.mahm.id
  storage_account_id     = azurerm_storage_account.mahm.id

  # Enable public network access for demo purposes
  public_network_access_enabled = true

  # Identity for the workspace
  identity {
    type = "SystemAssigned"
  }

  tags = local.common_tags
}

# Grant AI Foundry workspace access to Key Vault
resource "azurerm_key_vault_access_policy" "ai_foundry" {
  key_vault_id = azurerm_key_vault.mahm.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_machine_learning_workspace.ai_foundry.identity[0].principal_id

  secret_permissions = [
    "Get", "List"
  ]

  depends_on = [azurerm_machine_learning_workspace.ai_foundry]
}

# Store Application Insights connection string in Key Vault for Connected Agents
resource "azurerm_key_vault_secret" "application_insights_connection_string" {
  name         = "application-insights-connection-string"
  value        = azurerm_application_insights.mahm.connection_string
  key_vault_id = azurerm_key_vault.mahm.id

  depends_on = [azurerm_key_vault.mahm]
}