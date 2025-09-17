# MAHM Infrastructure

This directory contains Terraform configurations and scripts for deploying the Azure AI Foundry workspace and supporting infrastructure for MAHM (Multi-Agentic Hypertension Management).

## Directory Structure

```
infrastructure/
├── terraform/                 # Terraform configuration files
│   ├── main.tf               # Main resource definitions using Azure verified module
│   ├── variables.tf          # Input variables
│   ├── outputs.tf            # Output values
│   ├── locals.tf             # Local values and common tags
│   └── terraform.tfvars      # Variable values (created during deployment)
└── README.md                 # This file
```

## Azure Verified Module

This implementation uses the official Azure verified module:
- **Module**: `Azure/avm-ptn-aiml-ai-foundry/azurerm`
- **Version**: `0.6.0`
- **Documentation**: [Azure/terraform-azurerm-avm-ptn-aiml-ai-foundry](https://github.com/Azure/terraform-azurerm-avm-ptn-aiml-ai-foundry)

This module provides a comprehensive, tested, and officially supported pattern for deploying Azure AI Foundry workspaces.

## Quick Start

1. **Prerequisites**: Ensure Azure CLI and Terraform are installed
2. **Login**: `az login` and set your subscription
3. **Deploy**: Run `./scripts/deployment/deploy-azure-infrastructure.sh`
4. **Verify**: Run `./scripts/verification/verify-deployment.sh`

## Deployed Resources

The Azure verified module deploys the following Azure resources:

### Core Infrastructure
- **Resource Group**: Container for all MAHM resources
- **Azure AI Foundry Account**: Central AI services account
- **Azure AI Foundry Project**: Project workspace for Connected Agents
- **AI Agent Service**: Connected Agents runtime environment

### Supporting Services (BYOR - Bring Your Own Resources)
- **Storage Account**: Required for AI Foundry workspace
- **Azure Key Vault**: Secure storage for secrets and configuration
- **Log Analytics Workspace**: Centralized logging and monitoring

### Security & Authentication
- **System-assigned Managed Identity**: For AI Foundry workspace
- **RBAC Assignments**: Role-based access control for resources

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
key_vault_name = "mahm-kv-dev-001"
```

### Customization

Create a `terraform.tfvars` file in the `infrastructure/terraform` directory to override defaults:

```hcl
# Custom configuration
environment = "staging"
location = "UK West"
resource_group_name = "rg-mahm-staging"

# Custom resource names
resource_prefix = "mahm-staging"
key_vault_name = "mahm-kv-staging-001"
```

## Azure Verified Module Benefits

Using the official Azure verified module provides:

- **Best Practices**: Follows Microsoft's recommended patterns
- **Security**: Built-in security configurations and compliance
- **Reliability**: Tested and maintained by Microsoft
- **Support**: Official support from Microsoft
- **Updates**: Regular updates with new Azure features

## Security Configuration

### Managed Identities

- **System-assigned identity**: Created for AI Foundry workspace
- **Service identities**: Managed by the Azure verified module

### RBAC Assignments

- **Key Vault access**: Configured through the module
- **Storage access**: Managed by the module
- **AI Foundry permissions**: Automatically configured

### Key Vault Integration

The module automatically:
- Creates Key Vault with secure configuration
- Sets up proper access policies
- Manages secret storage for AI services

## Networking

### Public Access

For demonstration purposes, the deployment enables public network access. The Azure verified module supports:
- Public endpoints (current configuration)
- Private endpoints (for production use)
- VNet integration capabilities

### Production Considerations

The Azure verified module supports:
- Private endpoints for all resources
- Virtual network integration
- Network security configurations
- Advanced networking scenarios

## Monitoring and Observability

### Built-in Monitoring

The Azure verified module includes:
- Log Analytics Workspace integration
- Application Insights support
- Diagnostic settings
- Azure Monitor integration

### AI Foundry Monitoring

Configured for:
- AI service telemetry
- Project-level monitoring
- Agent performance tracking
- Cost tracking and optimization

## Cost Management

### Resource Sizing

The deployment uses minimal resource sizes suitable for development:
- **Storage Account**: Standard LRS replication
- **Key Vault**: Standard tier
- **AI Foundry**: Standard SKU

### Azure Verified Module Benefits

The module provides:
- Optimized resource configurations
- Cost-effective defaults
- Scalability planning support

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
4. **Module version**: Ensure using compatible Terraform version (>= 1.9)

### Useful Commands

```bash
# Show Terraform plan
cd infrastructure/terraform
terraform plan

# Show current state
terraform state list

# Get specific output
terraform output ai_foundry_workspace_name

# Show module outputs
terraform output connected_agents_configuration

# Destroy resources (use with caution)
terraform destroy
```

### Module-specific Troubleshooting

- Review module documentation: [Azure/terraform-azurerm-avm-ptn-aiml-ai-foundry](https://github.com/Azure/terraform-azurerm-avm-ptn-aiml-ai-foundry)
- Check module version compatibility
- Verify provider requirements are met

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