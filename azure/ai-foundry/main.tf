# Azure AI Foundry Infrastructure Templates

**⚠️ SIMULATION ONLY - NOT FOR CLINICAL USE ⚠️**

*Terraform templates for deploying My BP infrastructure to Azure AI Foundry using dummy data.*

## Terraform Configuration

### Variables

```hcl
# variables.tf
variable "environment" {
  description = "Environment name (dev, staging, demo)"
  type        = string
  default     = "demo"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "uksouth"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "mybp"
}

variable "admin_email" {
  description = "Administrator email for alerts"
  type        = string
  default     = "admin@mybp-demo.nhs.uk"
}

variable "dummy_data_enabled" {
  description = "Enable dummy data mode"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default = {
    Project     = "MyBP"
    Environment = "Demo"
    Purpose     = "Healthcare AI Demonstration"
    DataType    = "Dummy"
  }
}
```

### Main Infrastructure

```hcl
# main.tf
terraform {
  required_version = ">= 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.45"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {}

locals {
  resource_prefix = "${var.project_name}-${var.environment}"
  location_short  = var.location == "uksouth" ? "uks" : "ukw"
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "rg-${local.resource_prefix}-${local.location_short}"
  location = var.location
  tags     = var.tags
}

# Key Vault for secrets
resource "azurerm_key_vault" "main" {
  name                = "kv-${local.resource_prefix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tenant_id          = data.azurerm_client_config.current.tenant_id
  sku_name           = "standard"

  enabled_for_disk_encryption     = true
  enabled_for_template_deployment = true
  enabled_for_deployment          = true
  purge_protection_enabled        = false # Demo environment

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
      "List",
      "Create",
      "Delete",
      "Update"
    ]

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete"
    ]
  }

  tags = var.tags
}

# Application Insights
resource "azurerm_application_insights" "main" {
  name                = "ai-${local.resource_prefix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  application_type    = "web"
  retention_in_days   = 30 # Demo retention

  tags = var.tags
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "main" {
  name                = "la-${local.resource_prefix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30 # Demo retention

  tags = var.tags
}

# Storage Account for AI Foundry
resource "azurerm_storage_account" "main" {
  name                     = "st${replace(local.resource_prefix, "-", "")}${random_string.storage_suffix.result}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  # Demo security settings
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = true
  
  tags = var.tags
}

resource "random_string" "storage_suffix" {
  length  = 4
  special = false
  upper   = false
}

# Container Registry
resource "azurerm_container_registry" "main" {
  name                = "acr${replace(local.resource_prefix, "-", "")}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Basic"
  admin_enabled       = true

  tags = var.tags
}

# AI Foundry Workspace (Machine Learning Workspace)
resource "azurerm_machine_learning_workspace" "main" {
  name                          = "aifw-${local.resource_prefix}"
  location                      = azurerm_resource_group.main.location
  resource_group_name          = azurerm_resource_group.main.name
  application_insights_id       = azurerm_application_insights.main.id
  key_vault_id                 = azurerm_key_vault.main.id
  storage_account_id           = azurerm_storage_account.main.id
  container_registry_id        = azurerm_container_registry.main.id
  public_network_access_enabled = true # Demo environment

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# Azure API for FHIR
resource "azurerm_healthcare_service" "fhir" {
  name                = "fhir-${local.resource_prefix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  kind                = "fhir-R4"

  authentication_configuration {
    authority                     = "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}"
    audience                     = "https://${local.resource_prefix}-fhir.azurehealthcareapis.com"
    smart_proxy_enabled          = false
  }

  cors_configuration {
    allowed_origins     = ["*"] # Demo - restrict in production
    allowed_methods     = ["GET", "POST", "PUT", "DELETE"]
    allowed_headers     = ["*"]
    max_age_in_seconds = 86400
  }

  tags = var.tags
}

# Service Bus Namespace
resource "azurerm_servicebus_namespace" "main" {
  name                = "sb-${local.resource_prefix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"

  tags = var.tags
}

# Service Bus Topics for agent communication
resource "azurerm_servicebus_topic" "agent_coordination" {
  name         = "agent-coordination"
  namespace_id = azurerm_servicebus_namespace.main.id

  max_size_in_megabytes        = 5120
  default_message_ttl         = "P14D"
  auto_delete_on_idle         = "P10675199DT2H48M5.4775807S"
  duplicate_detection_enabled = true
}

resource "azurerm_servicebus_topic" "patient_events" {
  name         = "patient-events"
  namespace_id = azurerm_servicebus_namespace.main.id

  max_size_in_megabytes = 5120
  default_message_ttl  = "P14D"
}

resource "azurerm_servicebus_topic" "clinical_alerts" {
  name         = "clinical-alerts"
  namespace_id = azurerm_servicebus_namespace.main.id

  max_size_in_megabytes = 5120
  default_message_ttl  = "P14D"
}

resource "azurerm_servicebus_topic" "monitoring_data" {
  name         = "monitoring-data"
  namespace_id = azurerm_servicebus_namespace.main.id

  max_size_in_megabytes = 5120
  default_message_ttl  = "P7D"
}

resource "azurerm_servicebus_topic" "audit_trail" {
  name         = "audit-trail"
  namespace_id = azurerm_servicebus_namespace.main.id

  max_size_in_megabytes = 5120
  default_message_ttl  = "P90D" # Longer retention for audit
}

# Cosmos DB for application state
resource "azurerm_cosmosdb_account" "main" {
  name                = "cosmos-${local.resource_prefix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = azurerm_resource_group.main.location
    failover_priority = 0
  }

  backup {
    type                = "Continuous"
    interval_in_minutes = 240
    retention_in_hours  = 720 # 30 days for demo
  }

  tags = var.tags
}

resource "azurerm_cosmosdb_sql_database" "main" {
  name                = "mybp-demo-db"
  resource_group_name = azurerm_resource_group.main.name
  account_name        = azurerm_cosmosdb_account.main.name
  throughput          = 400
}

# Managed Identity for agents
resource "azurerm_user_assigned_identity" "agents" {
  name                = "id-${local.resource_prefix}-agents"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  tags = var.tags
}

# Role assignments for agent identity
resource "azurerm_role_assignment" "agents_keyvault" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.agents.principal_id
}

resource "azurerm_role_assignment" "agents_fhir" {
  scope                = azurerm_healthcare_service.fhir.id
  role_definition_name = "FHIR Data Contributor"
  principal_id         = azurerm_user_assigned_identity.agents.principal_id
}

resource "azurerm_role_assignment" "agents_servicebus" {
  scope                = azurerm_servicebus_namespace.main.id
  role_definition_name = "Azure Service Bus Data Owner"
  principal_id         = azurerm_user_assigned_identity.agents.principal_id
}

# Store secrets in Key Vault
resource "azurerm_key_vault_secret" "fhir_endpoint" {
  name         = "fhir-endpoint"
  value        = azurerm_healthcare_service.fhir.authentication_configuration[0].audience
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_key_vault.main]
}

resource "azurerm_key_vault_secret" "servicebus_connection" {
  name         = "servicebus-connection"
  value        = azurerm_servicebus_namespace.main.default_primary_connection_string
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_key_vault.main]
}

resource "azurerm_key_vault_secret" "cosmos_connection" {
  name         = "cosmos-connection"
  value        = azurerm_cosmosdb_account.main.primary_key
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_key_vault.main]
}

resource "azurerm_key_vault_secret" "application_insights_key" {
  name         = "application-insights-key"
  value        = azurerm_application_insights.main.instrumentation_key
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_key_vault.main]
}

# Data source for current Azure configuration
data "azurerm_client_config" "current" {}
```

### Agent Deployment Configuration

```hcl
# agents.tf
# Kubernetes cluster for agents (AKS)
resource "azurerm_kubernetes_cluster" "agents" {
  name                = "aks-${local.resource_prefix}-agents"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "${local.resource_prefix}-aks"

  default_node_pool {
    name       = "default"
    node_count = 3
    vm_size    = "Standard_D2s_v3"
    type       = "VirtualMachineScaleSets"
    
    # Demo configuration
    auto_scaling_enabled = true
    min_count           = 2
    max_count           = 10
  }

  identity {
    type = "SystemAssigned"
  }

  azure_policy_enabled             = true
  http_application_routing_enabled = false
  role_based_access_control_enabled = true

  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
  }

  tags = var.tags
}

# Role assignment for AKS to pull from ACR
resource "azurerm_role_assignment" "aks_acr" {
  principal_id                     = azurerm_kubernetes_cluster.agents.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                           = azurerm_container_registry.main.id
  skip_service_principal_aad_check = true
}

# Network Security Group for agents
resource "azurerm_network_security_group" "agents" {
  name                = "nsg-${local.resource_prefix}-agents"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.tags
}
```

### Monitoring and Alerting

```hcl
# monitoring.tf
# Action Group for alerts
resource "azurerm_monitor_action_group" "clinical_safety" {
  name                = "ag-${local.resource_prefix}-clinical-safety"
  resource_group_name = azurerm_resource_group.main.name
  short_name          = "clinical"

  email_receiver {
    name          = "admin"
    email_address = var.admin_email
  }

  webhook_receiver {
    name        = "teams"
    service_uri = "https://outlook.office.com/webhook/demo-teams-webhook"
  }

  tags = var.tags
}

resource "azurerm_monitor_action_group" "system_alerts" {
  name                = "ag-${local.resource_prefix}-system"
  resource_group_name = azurerm_resource_group.main.name
  short_name          = "system"

  email_receiver {
    name          = "devteam"
    email_address = "dev-team@mybp-demo.nhs.uk"
  }

  tags = var.tags
}

# Critical clinical event alert
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "critical_clinical_events" {
  name                = "alert-${local.resource_prefix}-critical-clinical"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  evaluation_frequency = "PT1M"
  window_duration      = "PT5M"
  scopes               = [azurerm_application_insights.main.id]
  severity             = 0 # Critical

  criteria {
    query = <<-QUERY
      customEvents
      | where name == "ClinicalSafetyEvent"
      | where customDimensions.severity == "critical"
      | where timestamp > ago(5m)
    QUERY

    time_aggregation_method = "Count"
    threshold               = 1
    operator                = "GreaterThanOrEqual"
  }

  action {
    action_groups = [azurerm_monitor_action_group.clinical_safety.id]
  }

  description = "Critical clinical safety event detected in My BP demo system"
  tags        = var.tags
}

# Agent failure rate alert
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "agent_failure_rate" {
  name                = "alert-${local.resource_prefix}-agent-failures"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  evaluation_frequency = "PT5M"
  window_duration      = "PT10M"
  scopes               = [azurerm_application_insights.main.id]
  severity             = 2 # Warning

  criteria {
    query = <<-QUERY
      customEvents
      | where name == "AgentExecution"
      | where timestamp > ago(10m)
      | summarize FailureRate = (countif(customDimensions.success == "false") * 100.0) / count() by tostring(customDimensions.agent_name)
      | where FailureRate > 10
    QUERY

    time_aggregation_method = "Count"
    threshold               = 1
    operator                = "GreaterThanOrEqual"
  }

  action {
    action_groups = [azurerm_monitor_action_group.system_alerts.id]
  }

  description = "Agent experiencing high failure rate in My BP demo system"
  tags        = var.tags
}

# FHIR service health alert
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "fhir_service_health" {
  name                = "alert-${local.resource_prefix}-fhir-health"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  evaluation_frequency = "PT2M"
  window_duration      = "PT5M"
  scopes               = [azurerm_application_insights.main.id]
  severity             = 1 # Error

  criteria {
    query = <<-QUERY
      customEvents
      | where name == "FHIROperation"
      | where timestamp > ago(5m)
      | summarize FailureRate = (countif(customDimensions.success == "false") * 100.0) / count()
      | where FailureRate > 5
    QUERY

    time_aggregation_method = "Count"
    threshold               = 1
    operator                = "GreaterThanOrEqual"
  }

  action {
    action_groups = [azurerm_monitor_action_group.clinical_safety.id]
  }

  description = "FHIR service experiencing issues in My BP demo system"
  tags        = var.tags
}
```

### Outputs

```hcl
# outputs.tf
output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "ai_foundry_workspace_name" {
  description = "The name of the AI Foundry workspace"
  value       = azurerm_machine_learning_workspace.main.name
}

output "fhir_service_name" {
  description = "The name of the FHIR service"
  value       = azurerm_healthcare_service.fhir.name
}

output "fhir_endpoint" {
  description = "The FHIR service endpoint"
  value       = azurerm_healthcare_service.fhir.authentication_configuration[0].audience
  sensitive   = false
}

output "key_vault_name" {
  description = "The name of the Key Vault"
  value       = azurerm_key_vault.main.name
}

output "container_registry_name" {
  description = "The name of the Container Registry"
  value       = azurerm_container_registry.main.name
}

output "container_registry_login_server" {
  description = "The login server of the Container Registry"
  value       = azurerm_container_registry.main.login_server
}

output "aks_cluster_name" {
  description = "The name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.agents.name
}

output "application_insights_instrumentation_key" {
  description = "The instrumentation key for Application Insights"
  value       = azurerm_application_insights.main.instrumentation_key
  sensitive   = true
}

output "application_insights_connection_string" {
  description = "The connection string for Application Insights"
  value       = azurerm_application_insights.main.connection_string
  sensitive   = true
}

output "servicebus_namespace_name" {
  description = "The name of the Service Bus namespace"
  value       = azurerm_servicebus_namespace.main.name
}

output "cosmos_db_account_name" {
  description = "The name of the Cosmos DB account"
  value       = azurerm_cosmosdb_account.main.name
}

output "managed_identity_client_id" {
  description = "The client ID of the managed identity for agents"
  value       = azurerm_user_assigned_identity.agents.client_id
}

output "deployment_summary" {
  description = "Summary of deployed resources"
  value = {
    environment           = var.environment
    location             = var.location
    resource_group       = azurerm_resource_group.main.name
    ai_foundry_workspace = azurerm_machine_learning_workspace.main.name
    fhir_service        = azurerm_healthcare_service.fhir.name
    container_registry  = azurerm_container_registry.main.login_server
    aks_cluster         = azurerm_kubernetes_cluster.agents.name
    dummy_data_enabled  = var.dummy_data_enabled
  }
}
```

---

**These Terraform templates provide comprehensive Azure infrastructure for the My BP system with proper security, monitoring, and dummy data configurations for demonstration purposes.**