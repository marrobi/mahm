terraform {
  required_version = ">= 1.9"
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.4"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    modtm = {
      source  = "azure/modtm"
      version = "~> 0.3"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azurerm" {
  storage_use_azuread = true
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
    cognitive_account {
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

# Azure AI Foundry deployment using Azure verified module
module "ai_foundry" {
  source  = "Azure/avm-ptn-aiml-ai-foundry/azurerm"
  version = "0.6.0"

  # Core required parameters
  base_name                  = var.resource_prefix
  location                   = azurerm_resource_group.mahm.location
  resource_group_resource_id = azurerm_resource_group.mahm.id

  # AI Foundry configuration
  ai_foundry = {
    name                     = var.ai_foundry_workspace_name
    create_ai_agent_service  = true
    allow_project_management = true
    disable_local_auth       = false
  }

  # AI Projects configuration
  ai_projects = {
    mahm_project = {
      name                       = "mahm-project"
      display_name               = "MAHM Connected Agents Project"
      description                = "Multi-Agentic Hypertension Management system with Connected Agents framework"
      create_project_connections = true
      storage_account_connection = {
        new_resource_map_key = "mahm"
      }
      key_vault_connection = {
        new_resource_map_key = "mahm"
      }
    }
  }

  # Storage account configuration (required for AI Foundry)
  storage_account_definition = {
    mahm = {
      name                      = var.storage_account_name
      account_tier              = "Standard"
      account_replication_type  = "LRS"
      account_kind              = "StorageV2"
      access_tier               = "Hot"
      shared_access_key_enabled = false
    }
  }

  # Key Vault configuration (required for AI Foundry)
  key_vault_definition = {
    mahm = {
      name      = var.key_vault_name
      sku       = "standard"
      tenant_id = data.azurerm_client_config.current.tenant_id
    }
  }

  # Enable BYOR (Bring Your Own Resources) to create the supporting services
  create_byor              = true
  create_private_endpoints = false

  # Tags
  tags = local.common_tags

  depends_on = [azurerm_resource_group.mahm]
}