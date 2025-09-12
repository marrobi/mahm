terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
    cognitive_account {
      purge_soft_delete_on_destroy = true
    }
  }
}

provider "azuread" {}

# Data sources for current context
data "azurerm_client_config" "current" {}
data "azuread_client_config" "current" {}

# Resource Group
resource "azurerm_resource_group" "mahm" {
  name     = var.resource_group_name
  location = var.location

  tags = local.common_tags
}

# Azure AI Foundry Workspace (Azure Machine Learning Workspace for AI Foundry)
resource "azurerm_machine_learning_workspace" "ai_foundry" {
  name                = var.ai_foundry_workspace_name
  location            = azurerm_resource_group.mahm.location
  resource_group_name = azurerm_resource_group.mahm.name

  # Required for AI Foundry
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

# Storage Account for AI Foundry workspace
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

# Application Insights for observability
resource "azurerm_application_insights" "mahm" {
  name                = var.application_insights_name
  location            = azurerm_resource_group.mahm.location
  resource_group_name = azurerm_resource_group.mahm.name
  application_type    = "web"

  tags = local.common_tags
}

# Key Vault for secure secret storage
resource "azurerm_key_vault" "mahm" {
  name                = var.key_vault_name
  location            = azurerm_resource_group.mahm.location
  resource_group_name = azurerm_resource_group.mahm.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  # Enable soft delete and purge protection for production
  soft_delete_retention_days = 7
  purge_protection_enabled   = false # Set to true for production

  # Access policies
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

  # Grant access to AI Foundry workspace managed identity
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_machine_learning_workspace.ai_foundry.identity[0].principal_id

    secret_permissions = [
      "Get", "List"
    ]
  }

  tags = local.common_tags
}

# Cosmos DB for conversation storage
resource "azurerm_cosmosdb_account" "mahm" {
  name                = var.cosmos_db_account_name
  location            = azurerm_resource_group.mahm.location
  resource_group_name = azurerm_resource_group.mahm.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = azurerm_resource_group.mahm.location
    failover_priority = 0
  }

  # Enable automatic failover
  enable_automatic_failover = true

  tags = local.common_tags
}

# Cosmos DB database for MAHM
resource "azurerm_cosmosdb_sql_database" "mahm" {
  name                = "mahm-conversations"
  resource_group_name = azurerm_resource_group.mahm.name
  account_name        = azurerm_cosmosdb_account.mahm.name
}

# Cosmos DB container for agent conversations
resource "azurerm_cosmosdb_sql_container" "conversations" {
  name                = "conversations"
  resource_group_name = azurerm_resource_group.mahm.name
  account_name        = azurerm_cosmosdb_account.mahm.name
  database_name       = azurerm_cosmosdb_sql_database.mahm.name
  partition_key_path  = "/conversationId"
  
  # Throughput for demo (can be scaled)
  throughput = 400
}

# Azure Health Data Services workspace (for FHIR API)
resource "azurerm_healthcare_workspace" "mahm" {
  name                = var.healthcare_workspace_name
  location            = azurerm_resource_group.mahm.location
  resource_group_name = azurerm_resource_group.mahm.name

  tags = local.common_tags
}

# FHIR Service
resource "azurerm_healthcare_fhir_service" "mahm" {
  name                = var.fhir_service_name
  location            = azurerm_resource_group.mahm.location
  resource_group_name = azurerm_resource_group.mahm.name
  workspace_id        = azurerm_healthcare_workspace.mahm.id

  kind = "fhir-R4"

  # Authentication configuration
  authentication {
    authority = "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}"
    audience  = "https://${var.healthcare_workspace_name}-${var.fhir_service_name}.fhir.azurehealthcareapis.com"
  }

  # Access policies for AI Foundry workspace
  access_policy_object_ids = [
    azurerm_machine_learning_workspace.ai_foundry.identity[0].principal_id
  ]

  tags = local.common_tags
}

# Managed Identity for agent applications
resource "azurerm_user_assigned_identity" "agents" {
  name                = "${var.resource_prefix}-agents-identity"
  location            = azurerm_resource_group.mahm.location
  resource_group_name = azurerm_resource_group.mahm.name

  tags = local.common_tags
}

# Role assignments for managed identities
resource "azurerm_role_assignment" "agents_cosmos_contributor" {
  scope                = azurerm_cosmosdb_account.mahm.id
  role_definition_name = "Cosmos DB Built-in Data Contributor"
  principal_id         = azurerm_user_assigned_identity.agents.principal_id
}

resource "azurerm_role_assignment" "agents_key_vault_user" {
  scope                = azurerm_key_vault.mahm.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.agents.principal_id
}

# Store connection strings and keys in Key Vault
resource "azurerm_key_vault_secret" "cosmos_connection_string" {
  name         = "cosmos-connection-string"
  value        = azurerm_cosmosdb_account.mahm.connection_strings[0]
  key_vault_id = azurerm_key_vault.mahm.id

  depends_on = [azurerm_key_vault.mahm]
}

resource "azurerm_key_vault_secret" "application_insights_key" {
  name         = "application-insights-instrumentation-key"
  value        = azurerm_application_insights.mahm.instrumentation_key
  key_vault_id = azurerm_key_vault.mahm.id

  depends_on = [azurerm_key_vault.mahm]
}

resource "azurerm_key_vault_secret" "fhir_service_url" {
  name         = "fhir-service-url"
  value        = "https://${azurerm_healthcare_workspace.mahm.name}-${azurerm_healthcare_fhir_service.mahm.name}.fhir.azurehealthcareapis.com"
  key_vault_id = azurerm_key_vault.mahm.id

  depends_on = [azurerm_key_vault.mahm]
}