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

output "ai_foundry_workspace_url" {
  description = "URL of the Azure AI Foundry workspace in Azure portal"
  value       = "https://ml.azure.com/workspaces/${azurerm_machine_learning_workspace.ai_foundry.name}/overview"
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = azurerm_key_vault.mahm.name
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = azurerm_key_vault.mahm.vault_uri
}

output "storage_account_name" {
  description = "Name of the Storage Account"
  value       = azurerm_storage_account.mahm.name
}

output "application_insights_name" {
  description = "Name of the Application Insights instance"
  value       = azurerm_application_insights.mahm.name
}

output "application_insights_connection_string" {
  description = "Application Insights connection string"
  value       = azurerm_application_insights.mahm.connection_string
  sensitive   = true
}

# Output for Connected Agents configuration
output "connected_agents_configuration" {
  description = "Configuration values for Connected Agents"
  value = {
    workspace_name           = azurerm_machine_learning_workspace.ai_foundry.name
    workspace_id            = azurerm_machine_learning_workspace.ai_foundry.id
    key_vault_uri           = azurerm_key_vault.mahm.vault_uri
    app_insights_connection = azurerm_application_insights.mahm.connection_string
    resource_group          = azurerm_resource_group.mahm.name
    location               = azurerm_resource_group.mahm.location
  }
  sensitive = true
}