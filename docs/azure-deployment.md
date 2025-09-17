# Azure AI Foundry Deployment Guide for MAHM

This guide provides comprehensive instructions for deploying and configuring the Azure AI Foundry workspace with Connected Agents for the MAHM (Multi-Agentic Hypertension Management) system.

## Overview

The deployment creates a focused Azure infrastructure supporting the MAHM Phase 1 objectives:
- Azure AI Foundry workspace for Connected Agents orchestration
- Azure Key Vault for secure secret management  
- Application Insights for observability and monitoring
- Storage Account for AI Foundry workspace requirements
- Managed identities for secure authentication

## Prerequisites

### Required Tools
- **Azure CLI** (version 2.40.0 or later)
- **Terraform** (version 1.0 or later)
- **jq** (for JSON processing in verification scripts)
- **Bash** (for running deployment scripts)

### Azure Requirements
- Active Azure subscription with appropriate permissions
- Contributor or Owner role on the target subscription
- Sufficient quota for the resources being deployed

### Installation Commands

```bash
# Install Azure CLI (Ubuntu/Debian)
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install Terraform
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# Install jq
sudo apt-get install jq
```

## Quick Start Deployment

### 1. Login to Azure
```bash
az login
az account set --subscription "<your-subscription-id>"
```

### 2. Clone and Navigate to Repository
```bash
git clone <repository-url>
cd mahm
```

### 3. Run Deployment Script
```bash
# Deploy with default settings (development environment)
./scripts/deployment/deploy-azure-infrastructure.sh

# Deploy with custom settings
./scripts/deployment/deploy-azure-infrastructure.sh \
  --environment dev \
  --location "UK South" \
  --subscription "<subscription-id>"
```

### 4. Verify Deployment
```bash
./scripts/verification/verify-deployment.sh
```

## Detailed Configuration

### Environment Variables

Create a `terraform.tfvars` file in the `infrastructure/terraform` directory to customize your deployment:

```hcl
# Environment configuration
environment = "dev"
location = "UK South"

# Resource naming
resource_group_name = "rg-mahm-dev"
resource_prefix = "mahm-dev"

# Specific resource names
ai_foundry_workspace_name = "mahm-ai-foundry-dev"
storage_account_name = "mahmaidevst001"
application_insights_name = "mahm-ai-insights-dev"
key_vault_name = "mahm-kv-dev-001"
cosmos_db_account_name = "mahm-cosmos-dev"
healthcare_workspace_name = "mahm-health-dev"
fhir_service_name = "mahm-fhir-dev"

# Metadata
project_name = "mahm"
cost_center = "demo"
owner = "mahm-team"
```

### Azure Regions

Recommended regions for MAHM deployment:
- **UK South** (primary, for NHS compliance)
- **UK West** (secondary, for redundancy)
- **West Europe** (alternative, GDPR compliant)

## Agent Configuration

### Main Orchestrating Agent

The central coordination agent that routes inquiries to specialized agents:

```json
{
  "name": "MainOrchestratingAgent",
  "type": "orchestrator",
  "capabilities": [
    "natural_language_routing",
    "clinical_safety_monitoring",
    "multi_agent_coordination",
    "emergency_detection"
  ]
}
```

### BP Monitoring Stub Agent

Specialized agent for blood pressure monitoring guidance:

```json
{
  "name": "BPMonitoringAgent",
  "type": "specialized",
  "capabilities": [
    "bp_measurement_guidance",
    "community_monitoring_coordination",
    "nice_guideline_interpretation"
  ]
}
```

### Routing Test Agent

Validation agent for testing system functionality:

```json
{
  "name": "RoutingTestAgent",
  "type": "test",
  "capabilities": [
    "routing_validation",
    "health_monitoring",
    "communication_testing"
  ]
}
```

## Security Configuration

### Managed Identities

The deployment creates the following managed identities:
- **System-assigned identity** for AI Foundry workspace
- **User-assigned identity** for agent applications

### Key Vault Access Policies

Configured access policies for:
- Deployment user (full access)
- AI Foundry workspace (secret read access)
- Agent managed identity (secret read access)

### RBAC Assignments

Role assignments include:
- Cosmos DB Built-in Data Contributor for agents
- Key Vault Secrets User for agents
- Application Insights Data Reader for monitoring

## Monitoring and Observability

### Application Insights Integration

All agents are configured to send telemetry to Application Insights:
- **Events**: Agent interactions and routing decisions
- **Dependencies**: External service calls (FHIR, Cosmos DB)
- **Exceptions**: Error handling and debugging
- **Custom Metrics**: Agent performance and health status

### Health Check Endpoints

Each agent exposes a health check endpoint:
```json
{
  "status": "healthy",
  "agent": "MainOrchestratingAgent",
  "capabilities": ["routing", "orchestration"],
  "timestamp": "2024-12-09T12:00:00Z"
}
```

### Correlation IDs

All requests include correlation IDs for tracing:
- Header: `x-correlation-id`
- Propagated across agent-to-agent communications
- Logged in Application Insights for debugging

## FHIR Integration (Phase 1 Stub)

### Azure Health Data Services

The deployment includes:
- **Healthcare workspace** for organizing FHIR resources
- **FHIR R4 service** for healthcare data standards
- **Authentication** via Azure AD/Managed Identity

### Phase 1 Implementation

For Phase 1, FHIR integration is stubbed:
- Service is deployed and accessible
- Authentication is configured
- Dummy data structure is defined
- Full integration planned for Phase 2

## Troubleshooting

### Common Issues

#### Terraform Deployment Failures

**Issue**: Resource name conflicts
```bash
Error: A resource with the ID "/subscriptions/.../providers/Microsoft.KeyVault/vaults/mahm-kv-dev-001" already exists
```

**Solution**: Update resource names in `terraform.tfvars`:
```hcl
key_vault_name = "mahm-kv-dev-002"
```

#### Permission Errors

**Issue**: Insufficient permissions
```bash
Error: authorization failed when checking for existence of existing resource
```

**Solution**: Verify Azure permissions:
```bash
az role assignment list --assignee $(az account show --query user.name -o tsv)
```

#### Agent Health Check Failures

**Issue**: Agent not responding to health checks
```bash
ERROR: Agent health check failed with status 404
```

**Solution**: 
1. Check agent configuration files
2. Verify managed identity permissions
3. Review Application Insights logs

### Log Analysis

#### Application Insights Queries

Monitor agent health:
```kusto
traces
| where timestamp > ago(1h)
| where message contains "health_check"
| summarize count() by bin(timestamp, 5m)
```

Track routing decisions:
```kusto
customEvents
| where name == "agent_routing"
| extend intent = tostring(customDimensions.intent)
| extend target_agent = tostring(customDimensions.target_agent)
| summarize count() by intent, target_agent
```

#### Cosmos DB Monitoring

Check conversation storage:
```sql
SELECT * FROM c WHERE c.conversationId = "<correlation-id>"
```

## Deployment Outputs

After successful deployment, the following outputs are available:

### Infrastructure Endpoints
- **AI Foundry Workspace**: Available in Azure Portal under Machine Learning
- **Key Vault URI**: `https://<vault-name>.vault.azure.net/`
- **Cosmos DB Endpoint**: `https://<account-name>.documents.azure.com:443/`
- **FHIR Service URL**: `https://<workspace>-<service>.fhir.azurehealthcareapis.com`

### Configuration Values
- **Managed Identity Client ID**: Used for agent authentication
- **Application Insights Instrumentation Key**: For telemetry
- **Connection Strings**: Stored securely in Key Vault

## Next Steps

### Phase 1 Completion
1. ✅ Deploy Azure AI Foundry workspace
2. ✅ Configure Connected Agents framework
3. ✅ Set up security and authentication
4. ✅ Implement observability
5. 🔄 Register agents in AI Foundry portal
6. 🔄 Test live agent communication

### Phase 2 Planning
1. Deploy additional specialized agents
2. Implement full FHIR integration
3. Add emergency detection capabilities
4. Enhance monitoring and alerting

## Support and Documentation

### Key Files
- `infrastructure/terraform/`: Terraform configuration files
- `agents/configurations/`: Agent configuration JSON files
- `scripts/deployment/`: Deployment automation scripts
- `scripts/verification/`: Testing and validation scripts

### Additional Resources
- [Azure AI Foundry Documentation](https://docs.microsoft.com/azure/machine-learning/)
- [Azure Health Data Services](https://docs.microsoft.com/azure/healthcare-apis/)
- [MAHM Technical Architecture](../technical-architecture.md)
- [Agent Development Guide](../agents.md)

---

**Note**: This deployment is configured for demonstration purposes with dummy data only. For production use, additional security hardening, compliance checks, and clinical safety validations would be required.