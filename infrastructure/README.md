# MAHM Infrastructure

This directory contains Terraform configurations and scripts for deploying the Azure AI Foundry workspace and supporting infrastructure for MAHM (Multi-Agentic Hypertension Management).

## Directory Structure

```
infrastructure/
├── terraform/                 # Terraform configuration files
│   ├── main.tf               # Main resource definitions
│   ├── variables.tf          # Input variables
│   ├── outputs.tf            # Output values
│   ├── locals.tf             # Local values and common tags
│   └── terraform.tfvars      # Variable values (created during deployment)
└── README.md                 # This file
```

## Quick Start

1. **Prerequisites**: Ensure Azure CLI and Terraform are installed
2. **Login**: `az login` and set your subscription
3. **Deploy**: Run `./scripts/deployment/deploy-azure-infrastructure.sh`
4. **Verify**: Run `./scripts/verification/verify-deployment.sh`

## Deployed Resources

The Terraform configuration deploys the following Azure resources:

### Core Infrastructure
- **Resource Group**: Container for all MAHM resources
- **Azure AI Foundry Workspace**: Machine Learning workspace for Connected Agents
- **Storage Account**: Required for AI Foundry workspace
- **Application Insights**: Observability and monitoring

### Security & Authentication
- **Azure Key Vault**: Secure storage for secrets and configuration
- **Managed Identity**: User-assigned identity for agent authentication
- **RBAC Assignments**: Role-based access control for resources

### Data Storage
- **Cosmos DB Account**: NoSQL database for conversation storage
- **Cosmos DB Database**: "mahm-conversations" database
- **Cosmos DB Container**: "conversations" container with partition key

### Healthcare Integration
- **Healthcare Workspace**: Azure Health Data Services workspace
- **FHIR Service**: FHIR R4 API for healthcare data (Phase 1 stub)

## Configuration

### Default Values

The deployment uses the following default values for development:

```hcl
environment = "dev"
location = "UK South"
resource_group_name = "rg-mahm-dev"
resource_prefix = "mahm-dev"
ai_foundry_workspace_name = "mahm-ai-foundry-dev"
storage_account_name = "mahmaidevst001"
application_insights_name = "mahm-ai-insights-dev"
key_vault_name = "mahm-kv-dev-001"
cosmos_db_account_name = "mahm-cosmos-dev"
healthcare_workspace_name = "mahm-health-dev"
fhir_service_name = "mahm-fhir-dev"
```

### Customization

Create a `terraform.tfvars` file in the `infrastructure/terraform` directory to override defaults:

```hcl
# Custom configuration
environment = "staging"
location = "UK West"
resource_group_name = "rg-mahm-staging"

# Custom resource names
cosmos_db_account_name = "mahm-cosmos-staging"
key_vault_name = "mahm-kv-staging-001"
```

## Security Configuration

### Managed Identities

- **System-assigned identity**: Created for AI Foundry workspace
- **User-assigned identity**: Created for agent applications with specific permissions

### RBAC Assignments

- **Cosmos DB Built-in Data Contributor**: Agent access to Cosmos DB
- **Key Vault Secrets User**: Agent access to Key Vault secrets

### Key Vault Access Policies

- **Deployment user**: Full access (keys, secrets, certificates)
- **AI Foundry workspace**: Secret read access
- **Agent identity**: Secret read access

### Stored Secrets

The following secrets are automatically stored in Key Vault:

- `cosmos-connection-string`: Cosmos DB connection string
- `application-insights-instrumentation-key`: App Insights key
- `fhir-service-url`: FHIR service endpoint URL

## Networking

### Public Access

For demonstration purposes, the deployment enables public network access on:
- AI Foundry workspace
- Storage account
- Key Vault
- Cosmos DB

### Production Considerations

For production deployment, consider:
- Private endpoints for all resources
- Virtual network integration
- Network security groups
- Application Gateway for web traffic

## Monitoring and Observability

### Application Insights

Configured for:
- Event tracking for agent interactions
- Dependency tracking for external services
- Exception tracking for error handling
- Custom metrics for agent performance

### Correlation IDs

All agents are configured to:
- Generate correlation IDs for request tracing
- Propagate correlation IDs across service calls
- Log correlation IDs in Application Insights

### Health Checks

Each agent exposes health check endpoints:
- `/health` endpoint for availability monitoring
- Structured JSON responses with status and metadata
- Integration with Application Insights for monitoring

## Cost Management

### Resource Sizing

The deployment uses minimal resource sizes suitable for development:
- **Cosmos DB**: 400 RU/s throughput
- **Storage Account**: Standard LRS replication
- **Key Vault**: Standard tier

### Cost Optimization

For production:
- Use reserved instances for Cosmos DB
- Implement auto-scaling for variable workloads
- Consider Azure Hybrid Benefit for compute resources

### Tagging Strategy

All resources are tagged with:
- `Project`: "mahm"
- `Environment`: Environment name (dev/staging/prod)
- `CostCenter`: Cost center for billing
- `Owner`: Resource owner
- `ManagedBy`: "terraform"
- `Purpose`: "mahm-ai-foundry-demo"
- `DataClassification`: "demo-data-only"

## Troubleshooting

### Common Issues

1. **Resource name conflicts**: Update names in `terraform.tfvars`
2. **Permission errors**: Verify Azure RBAC assignments
3. **Quota limits**: Check subscription quotas for the region

### Useful Commands

```bash
# Show Terraform plan
cd infrastructure/terraform
terraform plan

# Show current state
terraform state list

# Get specific output
terraform output ai_foundry_workspace_name

# Destroy resources (use with caution)
terraform destroy
```

### Log Analysis

Use Application Insights to monitor:
- Agent health checks
- Routing decisions
- Performance metrics
- Error patterns

## Integration with CI/CD

### GitHub Actions

Consider implementing:
- Terraform validation on pull requests
- Automated deployment to staging environments
- Resource drift detection
- Cost monitoring alerts

### Azure DevOps

Integration points:
- Variable groups for environment-specific values
- Service connections for authentication
- Pipeline templates for consistent deployments

## Next Steps

### Phase 1 Completion
1. Verify all resources are deployed successfully
2. Test agent health checks and routing
3. Validate security configuration
4. Configure monitoring dashboards

### Phase 2 Preparation
1. Plan for additional agent deployments
2. Implement production security hardening
3. Set up disaster recovery procedures
4. Configure automated backup strategies

---

For detailed deployment instructions, see [docs/azure-deployment.md](../../docs/azure-deployment.md).