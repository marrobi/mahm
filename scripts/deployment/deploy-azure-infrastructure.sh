#!/bin/bash

# MAHM Azure AI Foundry Deployment Script
# This script deploys the Azure AI Foundry workspace and supporting infrastructure for MAHM

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
ENVIRONMENT="dev"
LOCATION="uksouth"
SUBSCRIPTION_ID=""
TENANT_ID=""
RESOURCE_GROUP_PREFIX="rg-mahm"
TERRAFORM_DIR="$(dirname "$0")/../../infrastructure/terraform"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if Azure CLI is installed
    if ! command -v az &> /dev/null; then
        print_error "Azure CLI is not installed. Please install it first."
        exit 1
    fi
    
    # Check if Terraform is installed
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed. Please install it first."
        exit 1
    fi
    
    # Check if logged into Azure
    if ! az account show &> /dev/null; then
        print_error "Not logged into Azure. Please run 'az login' first."
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

# Function to validate Azure subscription and permissions
validate_azure_context() {
    print_status "Validating Azure context..."
    
    # Get current subscription
    CURRENT_SUB=$(az account show --query id -o tsv)
    print_status "Current subscription: $CURRENT_SUB"
    
    # Validate permissions
    if ! az role assignment list --assignee $(az account show --query user.name -o tsv) --scope "/subscriptions/$CURRENT_SUB" &> /dev/null; then
        print_warning "Unable to verify permissions. Ensure you have Contributor access to the subscription."
    fi
    
    print_success "Azure context validated"
}

# Function to initialize Terraform
init_terraform() {
    print_status "Initializing Terraform..."
    
    cd "$TERRAFORM_DIR"
    
    # Initialize Terraform
    terraform init
    
    # Validate Terraform configuration
    terraform validate
    
    print_success "Terraform initialized successfully"
}

# Function to plan Terraform deployment
plan_terraform() {
    print_status "Planning Terraform deployment..."
    
    cd "$TERRAFORM_DIR"
    
    # Create terraform.tfvars if it doesn't exist
    if [ ! -f "terraform.tfvars" ]; then
        cat > terraform.tfvars <<EOF
environment = "$ENVIRONMENT"
location = "$LOCATION"
resource_group_name = "${RESOURCE_GROUP_PREFIX}-${ENVIRONMENT}"
resource_prefix = "mahm-${ENVIRONMENT}"
EOF
        print_status "Created terraform.tfvars with default values"
    fi
    
    # Run terraform plan
    terraform plan -out=tfplan
    
    print_success "Terraform plan completed"
}

# Function to apply Terraform deployment
apply_terraform() {
    print_status "Applying Terraform deployment..."
    
    cd "$TERRAFORM_DIR"
    
    # Apply the plan
    terraform apply tfplan
    
    print_success "Terraform deployment completed"
}

# Function to get deployment outputs
get_outputs() {
    print_status "Retrieving deployment outputs..."
    
    cd "$TERRAFORM_DIR"
    
    # Get outputs
    echo -e "\n${GREEN}=== DEPLOYMENT OUTPUTS ===${NC}"
    terraform output
    
    # Save outputs to a file for later use
    terraform output -json > ../../outputs.json
    
    print_success "Outputs saved to outputs.json"
}

# Function to register agents
register_agents() {
    print_status "Registering MAHM agents..."
    
    # Note: Agent registration will be handled by the verification script
    # This is a placeholder for future agent registration logic
    
    print_status "Agent registration will be completed in the verification phase"
}

# Function to configure observability
setup_observability() {
    print_status "Setting up observability..."
    
    # Application Insights is already configured via Terraform
    # Additional observability setup can be added here
    
    print_success "Observability configuration completed"
}

# Function to display next steps
show_next_steps() {
    echo -e "\n${GREEN}=== DEPLOYMENT COMPLETED SUCCESSFULLY ===${NC}"
    echo -e "\n${BLUE}Next Steps:${NC}"
    echo "1. Run the verification script: ./scripts/verification/verify-deployment.sh"
    echo "2. Test agent health checks and routing"
    echo "3. Configure agent-to-agent communication"
    echo "4. Review the deployment documentation in docs/azure-deployment.md"
    echo -e "\n${BLUE}Important Files:${NC}"
    echo "- outputs.json: Contains deployment outputs and configuration"
    echo "- agents/configurations/: Agent configuration files"
    echo "- scripts/verification/: Verification and testing scripts"
    echo -e "\n${YELLOW}Note:${NC} All deployed resources are tagged for easy identification and cost tracking."
}

# Function to handle cleanup on error
cleanup_on_error() {
    print_error "Deployment failed. Check the output above for details."
    print_warning "You may need to run 'terraform destroy' to clean up partially created resources."
    exit 1
}

# Main deployment function
main() {
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}   MAHM Azure AI Foundry Deployment Script    ${NC}"
    echo -e "${BLUE}================================================${NC}"
    
    # Set error handler
    trap cleanup_on_error ERR
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --environment|-e)
                ENVIRONMENT="$2"
                shift 2
                ;;
            --location|-l)
                LOCATION="$2"
                shift 2
                ;;
            --subscription|-s)
                SUBSCRIPTION_ID="$2"
                shift 2
                ;;
            --help|-h)
                echo "Usage: $0 [OPTIONS]"
                echo "Options:"
                echo "  --environment, -e    Environment (dev, staging, prod) [default: dev]"
                echo "  --location, -l       Azure region [default: uksouth]"
                echo "  --subscription, -s   Azure subscription ID"
                echo "  --help, -h           Show this help message"
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    # Set subscription if provided
    if [ -n "$SUBSCRIPTION_ID" ]; then
        az account set --subscription "$SUBSCRIPTION_ID"
        print_status "Set active subscription to: $SUBSCRIPTION_ID"
    fi
    
    print_status "Deploying MAHM infrastructure with the following configuration:"
    print_status "Environment: $ENVIRONMENT"
    print_status "Location: $LOCATION"
    
    # Execute deployment steps
    check_prerequisites
    validate_azure_context
    init_terraform
    plan_terraform
    
    # Confirm before applying
    echo -e "\n${YELLOW}Are you sure you want to proceed with the deployment? (y/N)${NC}"
    read -r confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        print_status "Deployment cancelled by user"
        exit 0
    fi
    
    apply_terraform
    get_outputs
    register_agents
    setup_observability
    show_next_steps
    
    print_success "MAHM Azure AI Foundry deployment completed successfully!"
}

# Run main function
main "$@"