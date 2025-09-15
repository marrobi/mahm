output "resource_group_name" {
  description = "Name of the created resource group"
  value       = azurerm_resource_group.mahm.name
}

output "resource_group_id" {
  description = "ID of the created resource group"
  value       = azurerm_resource_group.mahm.id
}

output "ai_foundry_workspace_name" {
  description = "Name of the Azure AI Foundry workspace"
  value       = module.ai_foundry.ai_foundry_name
}

output "ai_foundry_workspace_id" {
  description = "ID of the Azure AI Foundry workspace"
  value       = module.ai_foundry.ai_foundry_id
}

output "ai_foundry_project_name" {
  description = "Name of the Azure AI Foundry project"
  value       = module.ai_foundry.ai_foundry_project_name
}

output "ai_foundry_project_id" {
  description = "ID of the Azure AI Foundry project"
  value       = module.ai_foundry.ai_foundry_project_id
}

output "ai_foundry_workspace_url" {
  description = "URL of the Azure AI Foundry workspace in Azure portal"
  value       = "https://ai.azure.com/projecthub/${module.ai_foundry.ai_foundry_project_id}"
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = module.ai_foundry.key_vault_name
}

output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = module.ai_foundry.key_vault_id
}

output "storage_account_name" {
  description = "Name of the Storage Account"
  value       = module.ai_foundry.storage_account_name
}

output "storage_account_id" {
  description = "ID of the Storage Account"
  value       = module.ai_foundry.storage_account_id
}

output "ai_agent_service_id" {
  description = "ID of the AI agent service (if enabled)"
  value       = module.ai_foundry.ai_agent_service_id
}

# Output for Connected Agents configuration
output "connected_agents_configuration" {
  description = "Configuration values for Connected Agents"
  value = {
    workspace_name      = module.ai_foundry.ai_foundry_name
    workspace_id        = module.ai_foundry.ai_foundry_id
    project_name        = module.ai_foundry.ai_foundry_project_name
    project_id          = module.ai_foundry.ai_foundry_project_id
    key_vault_name      = module.ai_foundry.key_vault_name
    key_vault_id        = module.ai_foundry.key_vault_id
    storage_account_id  = module.ai_foundry.storage_account_id
    resource_group      = azurerm_resource_group.mahm.name
    location            = azurerm_resource_group.mahm.location
    ai_agent_service_id = module.ai_foundry.ai_agent_service_id
  }
  sensitive = false
}