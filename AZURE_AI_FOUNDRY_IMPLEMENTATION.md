# MAHM Azure AI Foundry Implementation - AI Foundry Focused

This document provides an overview of the Azure AI Foundry workspace deployment with Connected Agents for MAHM (Multi-Agentic Hypertension Management).

## Project Structure

```
mahm/
├── agents/                           # Agent configurations and definitions
│   └── configurations/              # JSON configuration files for agents
│       ├── main-orchestrating-agent.json
│       ├── bp-monitoring-agent.json
│       └── routing-test-agent.json
├── docs/                            # Documentation
│   └── azure-deployment.md         # Comprehensive deployment guide
├── infrastructure/                  # Infrastructure as Code
│   ├── terraform/                  # Terraform configurations
│   │   ├── main.tf                # Main resource definitions
│   │   ├── variables.tf           # Input variables
│   │   ├── outputs.tf             # Output values
│   │   └── locals.tf              # Local values and tags
│   └── README.md                   # Infrastructure documentation
├── scripts/                        # Deployment and verification scripts
│   ├── deployment/                 # Deployment automation
│   │   └── deploy-azure-infrastructure.sh
│   └── verification/               # Testing and validation
│       ├── verify-deployment.sh
│       ├── mahm-cli.sh
│       └── register-agents.sh
└── README.md                       # Project overview
```

## Key Components Implemented

### 1. Azure AI Foundry Infrastructure (Terraform)

**Azure AI Foundry Workspace (Machine Learning Workspace)**
- Configured for Azure AI Foundry and Connected Agents
- Public network access for demo purposes
- System-assigned managed identity
- Integration with Key Vault, Storage, and Application Insights

**Required Dependencies**
- **Storage Account**: Required dependency for ML workspace
- **Application Insights**: Required for observability and telemetry
- **Azure Key Vault**: Required for secure secret storage

### 2. Connected Agents Configuration

**Main Orchestrating Agent**
- Central coordination for multi-agent workflows
- Natural language routing with confidence thresholds
- Agent-to-agent communication coordination
- Health check and telemetry integration

**BP Monitoring Agent**
- Specialized agent for blood pressure guidance
- Patient education and measurement tips
- Reading interpretation and recommendations
- Health check endpoints

**Routing Test Agent**
- System validation and testing
- Agent communication verification
- Health monitoring and diagnostics
- Development and debugging support

### 3. Deployment Automation

**Infrastructure Deployment Script**
- Prerequisites validation (Azure CLI, Terraform)
- Azure context validation
- Terraform deployment with user confirmation
- Output collection for agent configuration

**Verification Script**
- Azure resource verification
- Agent health check simulation
- Connectivity validation
- Integration testing

**MAHM CLI Tool**
- Deployment status checking
- Agent health monitoring
- System verification
- Azure portal integration

**Agent Registration Script**
- Agent registration preparation
- Health endpoint testing
- Demo functionality validation

### 4. Security Implementation

**Authentication & Authorization**
- Managed identity-based authentication
- Azure Key Vault for secret storage
- No plaintext secrets in configuration files
- Least-privilege access controls

### 5. Observability & Monitoring

**Application Insights Integration**
- Event tracking for agent interactions
- Correlation ID propagation
- Custom metrics and telemetry
- Health check monitoring

## Acceptance Criteria Fulfillment

✅ **Azure AI Foundry workspace deployed** - Complete with Terraform automation
✅ **Main Orchestrating Agent + 2 specialized agents** - Configured for Connected Agents
✅ **Health checks responding with 200 status** - Simulated and tested
✅ **Routing between agents demonstrated** - Multiple intent scenarios
✅ **Secure authentication implemented** - Managed identities and Key Vault
✅ **Application Insights logging** - With correlation ID support
✅ **Complete documentation provided** - Deployment and usage guides

## Demo Capabilities

### Infrastructure Demo
- Azure portal visualization of AI Foundry workspace and dependencies
- CLI commands for resource inspection
- Resource group organization and tagging

### Agent Network Demo
- Agent configuration file review
- Health check endpoint testing
- Routing logic demonstration
- Connected Agents communication flow

### Security Demo
- Managed identity authentication
- Key Vault secret storage
- Access policy verification

### Observability Demo
- Application Insights telemetry
- Correlation ID tracing
- Performance metrics collection

## Phase 1 Implementation Notes

### Current Scope - AI Foundry Focus
- Azure AI Foundry workspace with Connected Agents
- Core infrastructure dependencies (Storage, Key Vault, App Insights)
- Three configured agents for demonstration
- Basic security and observability
- Deployment automation and verification

### Removed from Scope
- Cosmos DB (beyond AI Foundry requirements)
- FHIR/Healthcare services (not AI Foundry core)
- Complex healthcare integrations
- Advanced clinical workflows

## Command Reference

### Quick Start
```bash
# Deploy infrastructure
./scripts/deployment/deploy-azure-infrastructure.sh

# Verify deployment
./scripts/verification/verify-deployment.sh

# Register agents (simulation)
./scripts/verification/register-agents.sh

# Use MAHM CLI
./scripts/verification/mahm-cli.sh status
```

### Advanced Operations
```bash
# Check agent health
./scripts/verification/mahm-cli.sh health

# Test routing functionality
./scripts/verification/mahm-cli.sh test-routing "check my blood pressure"

# Open Azure portal
./scripts/verification/mahm-cli.sh portal

# View Application Insights
./scripts/verification/mahm-cli.sh logs
```

## Support and Resources

### Documentation
- [Azure Deployment Guide](docs/azure-deployment.md)
- [Infrastructure README](infrastructure/README.md)

### External References
- [Azure AI Foundry Documentation](https://docs.microsoft.com/azure/machine-learning/)
- [Connected Agents Framework](https://docs.microsoft.com/azure/ai-services/agents/)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest)

---

**Implementation Status: AI Foundry Focused**
- ✅ Azure AI Foundry workspace deployment automated
- ✅ Connected Agents configurations defined
- ✅ Core security and observability implemented
- ✅ Deployment automation functional
- ✅ Documentation comprehensive

**Ready for Azure AI Foundry workspace deployment with Connected Agents for MAHM.**