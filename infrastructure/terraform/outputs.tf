output "resource_group_name" {
  description = "Name of the created resource group"
  value       = azurerm_resource_group.mahm.name
}

output "ai_foundry_workspace_name" {
  description = "Name of the Azure AI Foundry workspace"
  value       = azurerm_machine_learning_workspace.ai_foundry.name
}

output "ai_foundry_workspace_id" {
  description = "ID of the Azure AI Foundry workspace"
  value       = azurerm_machine_learning_workspace.ai_foundry.id
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = azurerm_key_vault.mahm.name
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = azurerm_key_vault.mahm.vault_uri
}

output "cosmos_db_account_name" {
  description = "Name of the Cosmos DB account"
  value       = azurerm_cosmosdb_account.mahm.name
}

output "cosmos_db_endpoint" {
  description = "Endpoint of the Cosmos DB account"
  value       = azurerm_cosmosdb_account.mahm.endpoint
}

output "application_insights_name" {
  description = "Name of the Application Insights instance"
  value       = azurerm_application_insights.mahm.name
}

output "application_insights_instrumentation_key" {
  description = "Application Insights instrumentation key"
  value       = azurerm_application_insights.mahm.instrumentation_key
  sensitive   = true
}

output "application_insights_connection_string" {
  description = "Application Insights connection string"
  value       = azurerm_application_insights.mahm.connection_string
  sensitive   = true
}

output "fhir_service_url" {
  description = "URL of the FHIR service"
  value       = "https://${azurerm_healthcare_workspace.mahm.name}-${azurerm_healthcare_fhir_service.mahm.name}.fhir.azurehealthcareapis.com"
}

output "managed_identity_principal_id" {
  description = "Principal ID of the managed identity for agents"
  value       = azurerm_user_assigned_identity.agents.principal_id
}

output "managed_identity_client_id" {
  description = "Client ID of the managed identity for agents"
  value       = azurerm_user_assigned_identity.agents.client_id
}

# Output for agent configuration
output "agent_configuration" {
  description = "Configuration values for agents"
  value = {
    key_vault_uri    = azurerm_key_vault.mahm.vault_uri
    cosmos_endpoint  = azurerm_cosmosdb_account.mahm.endpoint
    fhir_service_url = "https://${azurerm_healthcare_workspace.mahm.name}-${azurerm_healthcare_fhir_service.mahm.name}.fhir.azurehealthcareapis.com"
    app_insights_key = azurerm_application_insights.mahm.instrumentation_key
  }
  sensitive = true
}