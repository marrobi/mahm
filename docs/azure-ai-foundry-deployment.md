# Azure AI Foundry Deployment Guide for My BP

**⚠️ SIMULATION ONLY - NOT FOR CLINICAL USE ⚠️**

*This guide provides step-by-step instructions for deploying the My BP multi-agentic AI hypertension management system on Azure AI Foundry using dummy data only.*

## Prerequisites

### Azure Subscription Requirements
- Azure subscription with AI Foundry access
- Resource Provider registrations:
  - `Microsoft.MachineLearningServices`
  - `Microsoft.HealthcareApis` 
  - `Microsoft.ServiceBus`
  - `Microsoft.DocumentDB`
  - `Microsoft.KeyVault`
  - `Microsoft.Insights`

### Development Environment
```bash
# Required CLI tools
az --version              # Azure CLI 2.50+
terraform --version       # Terraform 1.5+
docker --version          # Docker 24.0+
kubectl version           # Kubernetes CLI 1.28+

# Azure CLI extensions
az extension add --name ai-foundry
az extension add --name healthcareapis
az extension add --name servicebus
```

### Permissions Required
- `Contributor` role on target subscription
- `User Access Administrator` for RBAC assignments
- `AI Foundry Administrator` role (if available)

## Deployment Architecture

### Resource Naming Convention
```yaml
naming_convention:
  resource_group: "rg-mybp-{environment}-{location}"
  ai_foundry: "aifw-mybp-{environment}"
  fhir_service: "fhir-mybp-{environment}"
  service_bus: "sb-mybp-{environment}"
  cosmos_db: "cosmos-mybp-{environment}"
  key_vault: "kv-mybp-{environment}"
  container_registry: "acrmybp{environment}"
  
environments:
  - dev
  - staging  
  - demo
  
locations:
  - uksouth
  - ukwest
  - westeurope
```

## Step 1: Infrastructure Deployment

### 1.1 Initialize Terraform

```bash
# Clone repository and navigate to infrastructure
cd /home/runner/work/mahm/mahm
terraform -chdir=azure/ai-foundry init

# Create terraform.tfvars
cat > azure/ai-foundry/terraform.tfvars << EOF
environment = "demo"
location = "uksouth"
project_name = "mybp"
admin_email = "admin@example.com"
dummy_data_enabled = true
EOF
```

### 1.2 Deploy Core Infrastructure

```bash
# Plan deployment
terraform -chdir=azure/ai-foundry plan -out=tfplan

# Apply infrastructure
terraform -chdir=azure/ai-foundry apply tfplan

# Capture output values
terraform -chdir=azure/ai-foundry output -json > deployment-outputs.json
```

### 1.3 Verify Infrastructure Deployment

```bash
# Check resource group
az group show --name "rg-mybp-demo-uksouth"

# Verify AI Foundry workspace
az ml workspace show --name "aifw-mybp-demo" --resource-group "rg-mybp-demo-uksouth"

# Check FHIR service
az healthcareapis service show --name "fhir-mybp-demo" --resource-group "rg-mybp-demo-uksouth"
```

## Step 2: Azure API for FHIR Configuration

### 2.1 FHIR Service Setup

```bash
# Configure FHIR service
FHIR_SERVICE_NAME="fhir-mybp-demo"
RESOURCE_GROUP="rg-mybp-demo-uksouth"

# Enable system-assigned managed identity
az healthcareapis service update \
  --name $FHIR_SERVICE_NAME \
  --resource-group $RESOURCE_GROUP \
  --identity-type SystemAssigned

# Get FHIR service URL
FHIR_URL=$(az healthcareapis service show \
  --name $FHIR_SERVICE_NAME \
  --resource-group $RESOURCE_GROUP \
  --query "properties.authenticationConfiguration.audience" -o tsv)

echo "FHIR Service URL: $FHIR_URL"
```

### 2.2 FHIR Access Configuration

```bash
# Create service principal for agent access
AGENT_SP=$(az ad sp create-for-rbac \
  --name "sp-mybp-agents-demo" \
  --role "FHIR Data Contributor" \
  --scopes "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.HealthcareApis/services/$FHIR_SERVICE_NAME")

# Store credentials in Key Vault
KV_NAME="kv-mybp-demo"
echo $AGENT_SP | jq -r '.appId' | az keyvault secret set --vault-name $KV_NAME --name "fhir-client-id" --value @-
echo $AGENT_SP | jq -r '.password' | az keyvault secret set --vault-name $KV_NAME --name "fhir-client-secret" --value @-
echo $AGENT_SP | jq -r '.tenant' | az keyvault secret set --vault-name $KV_NAME --name "fhir-tenant-id" --value @-
az keyvault secret set --vault-name $KV_NAME --name "fhir-endpoint" --value $FHIR_URL
```

### 2.3 Load Dummy FHIR Data

```bash
# Upload dummy data schemas
cd schemas
python load_dummy_data.py \
  --fhir-endpoint $FHIR_URL \
  --client-id $(az keyvault secret show --vault-name $KV_NAME --name "fhir-client-id" --query value -o tsv) \
  --client-secret $(az keyvault secret show --vault-name $KV_NAME --name "fhir-client-secret" --query value -o tsv) \
  --tenant-id $(az keyvault secret show --vault-name $KV_NAME --name "fhir-tenant-id" --query value -o tsv)
```

## Step 3: AI Foundry Workspace Setup

### 3.1 Create AI Foundry Project

```bash
# Create AI Foundry project for My BP
az ml workspace create \
  --name "aifw-mybp-demo" \
  --resource-group $RESOURCE_GROUP \
  --location "uksouth" \
  --display-name "My BP Hypertension Management Demo" \
  --description "Multi-agentic AI hypertension management system using dummy data"

# Configure workspace
az ml workspace update \
  --name "aifw-mybp-demo" \
  --resource-group $RESOURCE_GROUP \
  --set tags.Environment=demo tags.Purpose="Healthcare AI Demo"
```

### 3.2 Create Compute Resources

```bash
# Create compute cluster for agent training/fine-tuning
az ml compute create \
  --name "cluster-agents" \
  --type amlcompute \
  --workspace-name "aifw-mybp-demo" \
  --resource-group $RESOURCE_GROUP \
  --min-instances 0 \
  --max-instances 10 \
  --size "Standard_D2s_v3"

# Create inference endpoints for agents
for agent in orchestrating bp-measurement diagnosing lifestyle shared-decision-making titration monitoring medication-adherence red-flag; do
  az ml online-endpoint create \
    --name "endpoint-${agent}" \
    --workspace-name "aifw-mybp-demo" \
    --resource-group $RESOURCE_GROUP \
    --auth-mode key
done
```

### 3.3 Configure Model Registry

```bash
# Register base models for agents
az ml model create \
  --name "agent-base-model" \
  --version 1 \
  --type custom_model \
  --path "models/base/" \
  --workspace-name "aifw-mybp-demo" \
  --resource-group $RESOURCE_GROUP \
  --description "Base model for clinical AI agents"
```

## Step 4: Agent Deployment

### 4.1 Build Agent Container Images

```bash
# Build all agent images
cd agents
for agent_dir in */; do
  agent_name=$(basename "$agent_dir")
  echo "Building ${agent_name} agent..."
  
  docker build -t "acrmybpdemo.azurecr.io/agents/${agent_name}:latest" "${agent_dir}"
  docker push "acrmybpdemo.azurecr.io/agents/${agent_name}:latest"
done
```

### 4.2 Deploy Agents to AI Foundry

```bash
# Deploy each agent
for agent in orchestrating bp-measurement diagnosing lifestyle shared-decision-making titration monitoring medication-adherence red-flag; do
  echo "Deploying ${agent} agent..."
  
  az ml online-deployment create \
    --name "${agent}-deployment" \
    --endpoint-name "endpoint-${agent}" \
    --model "agent-base-model:1" \
    --instance-type "Standard_DS2_v2" \
    --instance-count 2 \
    --workspace-name "aifw-mybp-demo" \
    --resource-group $RESOURCE_GROUP \
    --file "azure/ai-foundry/deployments/${agent}-deployment.yml"
  
  # Set traffic to 100% for this deployment
  az ml online-endpoint update \
    --name "endpoint-${agent}" \
    --traffic "${agent}-deployment=100" \
    --workspace-name "aifw-mybp-demo" \
    --resource-group $RESOURCE_GROUP
done
```

### 4.3 Agent Configuration

Create agent configuration files:

```yaml
# azure/ai-foundry/deployments/orchestrating-deployment.yml
$schema: https://azuremlschemas.azureedge.net/latest/managedOnlineDeployment.schema.json
name: orchestrating-deployment
endpoint_name: endpoint-orchestrating
model: azureml:agent-base-model:1
environment:
  image: acrmybpdemo.azurecr.io/agents/orchestrating:latest
  environment_variables:
    AGENT_TYPE: "orchestrating"
    FHIR_ENDPOINT: "{{SECRET:fhir-endpoint}}"
    SERVICE_BUS_CONNECTION: "{{SECRET:servicebus-connection}}"
    LOG_LEVEL: "INFO"
instance_type: Standard_DS2_v2
instance_count: 3
request_settings:
  request_timeout_ms: 90000
  max_concurrent_requests_per_instance: 10
environment_variables:
  PYTHONPATH: "/app"
  AZURE_CLIENT_ID: "{{SECRET:fhir-client-id}}"
  AZURE_CLIENT_SECRET: "{{SECRET:fhir-client-secret}}"
  AZURE_TENANT_ID: "{{SECRET:fhir-tenant-id}}"
liveness_probe:
  failure_threshold: 3
  success_threshold: 1
  timeout: 30
  period: 30
  initial_delay: 60
readiness_probe:
  failure_threshold: 3
  success_threshold: 1
  timeout: 10
  period: 10
  initial_delay: 10
```

## Step 5: Service Bus Configuration

### 5.1 Create Topics and Subscriptions

```bash
# Service Bus namespace
SB_NAMESPACE="sb-mybp-demo"

# Create topics for agent communication
declare -a topics=("agent-coordination" "patient-events" "clinical-alerts" "monitoring-data" "audit-trail")

for topic in "${topics[@]}"; do
  az servicebus topic create \
    --resource-group $RESOURCE_GROUP \
    --namespace-name $SB_NAMESPACE \
    --name $topic \
    --max-size 5120 \
    --default-message-time-to-live P14D
done

# Create subscriptions for each agent
declare -a agents=("orchestrating" "bp-measurement" "diagnosing" "lifestyle" "shared-decision-making" "titration" "monitoring" "medication-adherence" "red-flag")

for agent in "${agents[@]}"; do
  for topic in "${topics[@]}"; do
    az servicebus topic subscription create \
      --resource-group $RESOURCE_GROUP \
      --namespace-name $SB_NAMESPACE \
      --topic-name $topic \
      --name "${agent}-subscription" \
      --max-delivery-count 10 \
      --lock-duration PT5M
  done
done
```

### 5.2 Configure Message Routing

```bash
# Create subscription filters for targeted messaging
az servicebus topic subscription rule create \
  --resource-group $RESOURCE_GROUP \
  --namespace-name $SB_NAMESPACE \
  --topic-name "clinical-alerts" \
  --subscription-name "red-flag-subscription" \
  --name "CriticalAlertsOnly" \
  --filter-type SqlFilter \
  --filter-sql-expression "priority='CRITICAL' OR messageType='ALERT'"

# Store Service Bus connection string
SB_CONNECTION=$(az servicebus namespace authorization-rule keys list \
  --resource-group $RESOURCE_GROUP \
  --namespace-name $SB_NAMESPACE \
  --name "RootManageSharedAccessKey" \
  --query primaryConnectionString -o tsv)

az keyvault secret set \
  --vault-name $KV_NAME \
  --name "servicebus-connection" \
  --value "$SB_CONNECTION"
```

## Step 6: Monitoring Setup

### 6.1 Application Insights Configuration

```bash
# Create Application Insights instance
AI_NAME="ai-mybp-demo"
az monitor app-insights component create \
  --app $AI_NAME \
  --location "uksouth" \
  --resource-group $RESOURCE_GROUP \
  --kind web \
  --application-type web

# Get instrumentation key
AI_KEY=$(az monitor app-insights component show \
  --app $AI_NAME \
  --resource-group $RESOURCE_GROUP \
  --query instrumentationKey -o tsv)

# Store in Key Vault
az keyvault secret set \
  --vault-name $KV_NAME \
  --name "application-insights-key" \
  --value "$AI_KEY"
```

### 6.2 Configure Agent Monitoring

```bash
# Create custom metrics for clinical safety
az monitor metrics alert create \
  --name "CriticalAlertResponse" \
  --resource-group $RESOURCE_GROUP \
  --scopes "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Insights/components/$AI_NAME" \
  --condition "count 'customEvents' where name == 'SafetyAlert' and customDimensions.urgency == 'critical' > 0" \
  --window-size 5m \
  --evaluation-frequency 1m \
  --severity 0 \
  --description "Critical clinical safety alert detected"

# Agent health monitoring
az monitor metrics alert create \
  --name "AgentHealthCheck" \
  --resource-group $RESOURCE_GROUP \
  --scopes "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Insights/components/$AI_NAME" \
  --condition "count 'customEvents' where name == 'AgentExecution' and customDimensions.success == 'false' > 5" \
  --window-size 10m \
  --evaluation-frequency 5m \
  --severity 2 \
  --description "Multiple agent execution failures detected"
```

## Step 7: Security Configuration

### 7.1 Network Security

```bash
# Create virtual network for secure communication
az network vnet create \
  --name "vnet-mybp-demo" \
  --resource-group $RESOURCE_GROUP \
  --location "uksouth" \
  --address-prefix "10.0.0.0/16" \
  --subnet-name "agents-subnet" \
  --subnet-prefix "10.0.1.0/24"

# Create private endpoints for FHIR service
az network private-endpoint create \
  --name "pe-fhir-mybp-demo" \
  --resource-group $RESOURCE_GROUP \
  --vnet-name "vnet-mybp-demo" \
  --subnet "agents-subnet" \
  --private-connection-resource-id "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.HealthcareApis/services/$FHIR_SERVICE_NAME" \
  --group-id fhir \
  --connection-name "fhir-private-connection"
```

### 7.2 Access Control Configuration

```bash
# Create managed identity for agents
AGENT_IDENTITY=$(az identity create \
  --name "id-mybp-agents-demo" \
  --resource-group $RESOURCE_GROUP \
  --query principalId -o tsv)

# Grant Key Vault access
az keyvault set-policy \
  --name $KV_NAME \
  --object-id $AGENT_IDENTITY \
  --secret-permissions get list

# Grant FHIR access
az role assignment create \
  --assignee $AGENT_IDENTITY \
  --role "FHIR Data Contributor" \
  --scope "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.HealthcareApis/services/$FHIR_SERVICE_NAME"
```

## Step 8: Validation and Testing

### 8.1 Deployment Validation

```bash
# Test agent endpoints
for agent in orchestrating bp-measurement diagnosing lifestyle shared-decision-making titration monitoring medication-adherence red-flag; do
  echo "Testing ${agent} agent endpoint..."
  
  ENDPOINT_URL=$(az ml online-endpoint show \
    --name "endpoint-${agent}" \
    --workspace-name "aifw-mybp-demo" \
    --resource-group $RESOURCE_GROUP \
    --query scoring_uri -o tsv)
  
  # Health check
  curl -X GET "${ENDPOINT_URL}/health" \
    -H "Authorization: Bearer $(az ml online-endpoint get-credentials --name endpoint-${agent} --workspace-name aifw-mybp-demo --resource-group $RESOURCE_GROUP --query primaryKey -o tsv)"
done
```

### 8.2 FHIR Data Validation

```bash
# Test FHIR service connectivity
python -c "
import requests
import json
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient

# Get credentials from Key Vault
kv_client = SecretClient('https://kv-mybp-demo.vault.azure.net/', DefaultAzureCredential())
fhir_endpoint = kv_client.get_secret('fhir-endpoint').value

# Test FHIR metadata endpoint
response = requests.get(f'{fhir_endpoint}/metadata')
print(f'FHIR Status: {response.status_code}')
print(f'FHIR Version: {response.json().get(\"fhirVersion\", \"Unknown\")}')
"
```

### 8.3 End-to-End Testing

```bash
# Run integration tests
cd tests
python -m pytest integration/ \
  --fhir-endpoint $(az keyvault secret show --vault-name $KV_NAME --name "fhir-endpoint" --query value -o tsv) \
  --servicebus-connection $(az keyvault secret show --vault-name $KV_NAME --name "servicebus-connection" --query value -o tsv) \
  --dummy-data-only \
  --verbose
```

## Step 9: Operations Setup

### 9.1 Backup Configuration

```bash
# Configure backup for Cosmos DB
az cosmosdb sql database create \
  --account-name "cosmos-mybp-demo" \
  --resource-group $RESOURCE_GROUP \
  --name "backup-config" \
  --throughput 400

# Enable point-in-time restore
az cosmosdb update \
  --name "cosmos-mybp-demo" \
  --resource-group $RESOURCE_GROUP \
  --backup-policy-type Continuous
```

### 9.2 Scaling Configuration

```bash
# Configure auto-scaling for agent endpoints
for agent in orchestrating red-flag; do
  az ml online-endpoint update \
    --name "endpoint-${agent}" \
    --workspace-name "aifw-mybp-demo" \
    --resource-group $RESOURCE_GROUP \
    --set deployments.${agent}-deployment.scale_settings.type=TargetUtilization \
    --set deployments.${agent}-deployment.scale_settings.min_instances=2 \
    --set deployments.${agent}-deployment.scale_settings.max_instances=10 \
    --set deployments.${agent}-deployment.scale_settings.target_utilization_percentage=70
done
```

## Step 10: Documentation and Handover

### 10.1 Generate Documentation

```bash
# Create deployment summary
cat > deployment-summary.md << EOF
# My BP Azure AI Foundry Deployment Summary

## Environment Details
- **Environment**: demo
- **Location**: uksouth  
- **Resource Group**: rg-mybp-demo-uksouth
- **Deployment Date**: $(date)

## Deployed Services
- AI Foundry Workspace: aifw-mybp-demo
- FHIR Service: fhir-mybp-demo
- Service Bus: sb-mybp-demo
- Key Vault: kv-mybp-demo
- Application Insights: ai-mybp-demo

## Agent Endpoints
$(for agent in orchestrating bp-measurement diagnosing lifestyle shared-decision-making titration monitoring medication-adherence red-flag; do
  echo "- ${agent}: $(az ml online-endpoint show --name endpoint-${agent} --workspace-name aifw-mybp-demo --resource-group rg-mybp-demo-uksouth --query scoring_uri -o tsv)"
done)

## Access Details
- FHIR Endpoint: $(az keyvault secret show --vault-name kv-mybp-demo --name fhir-endpoint --query value -o tsv)
- Key Vault: https://kv-mybp-demo.vault.azure.net/
- Monitoring: https://portal.azure.com/#@/resource/subscriptions/$(az account show --query id -o tsv)/resourceGroups/rg-mybp-demo-uksouth/providers/Microsoft.Insights/components/ai-mybp-demo

## Important Notes
- All data is dummy/simulated for demonstration purposes only
- System is configured for demo environment with appropriate scaling limits
- Clinical safety monitoring is active with alerting configured
EOF
```

### 10.2 Create Runbooks

```bash
# Create operational runbooks
mkdir -p docs/runbooks

cat > docs/runbooks/incident-response.md << EOF
# My BP Incident Response Runbook

## Critical Alert Response
1. Check Application Insights for error details
2. Verify agent health endpoints
3. Check FHIR service connectivity
4. Review Service Bus message queues
5. Escalate to on-call engineer if unresolved in 15 minutes

## Agent Restart Procedure
\`\`\`bash
# Restart specific agent
az ml online-deployment update \\
  --name {agent}-deployment \\
  --endpoint-name endpoint-{agent} \\
  --instance-count 0
  
sleep 30

az ml online-deployment update \\
  --name {agent}-deployment \\
  --endpoint-name endpoint-{agent} \\
  --instance-count 2
\`\`\`
EOF
```

## Troubleshooting

### Common Issues

1. **Agent Deployment Failures**
   ```bash
   # Check deployment logs
   az ml online-deployment get-logs \
     --name {agent}-deployment \
     --endpoint-name endpoint-{agent} \
     --workspace-name aifw-mybp-demo \
     --resource-group $RESOURCE_GROUP
   ```

2. **FHIR Connectivity Issues**
   ```bash
   # Test FHIR authentication
   az account get-access-token --resource=https://fhir.azurehealthcareapis.com
   ```

3. **Service Bus Message Failures**
   ```bash
   # Check dead letter queues
   az servicebus topic subscription show \
     --resource-group $RESOURCE_GROUP \
     --namespace-name $SB_NAMESPACE \
     --topic-name agent-coordination \
     --name orchestrating-subscription
   ```

### Support Contacts

- **Azure Support**: Create ticket through Azure Portal
- **Development Team**: See repository CODEOWNERS file
- **Security Issues**: security@example.com

---

**Deployment Complete! 🎉**

Your My BP multi-agentic AI system is now deployed on Azure AI Foundry with dummy data. Review the deployment summary and runbooks for operational guidance.

*Remember: This is a demonstration system using simulated data only.*