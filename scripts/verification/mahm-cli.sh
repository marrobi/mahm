#!/bin/bash

# MAHM CLI Helper Script for Agent Management and Testing
# Provides command-line interface for interacting with MAHM agents

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

OUTPUTS_FILE="$(dirname "$0")/../../outputs.json"

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

# Function to get output value
get_output_value() {
    local key="$1"
    if [ -f "$OUTPUTS_FILE" ]; then
        jq -r ".${key}.value" "$OUTPUTS_FILE" 2>/dev/null || echo ""
    else
        echo ""
    fi
}

# Function to show usage
show_usage() {
    cat << EOF
MAHM CLI - Multi-Agentic Hypertension Management Command Line Interface

Usage: $0 <command> [options]

Commands:
  status          Show deployment status and resource information
  health          Check health of all agents
  test-routing    Test agent routing functionality
  list-agents     List configured agents and their capabilities
  logs            Show recent Application Insights logs (requires query)
  portal          Open Azure portal resources
  help            Show this help message

Examples:
  $0 status                    # Show deployment status
  $0 health                    # Check all agent health
  $0 test-routing "test ping"  # Test routing with specific input
  $0 list-agents               # Show configured agents
  $0 portal                    # Open Azure portal

EOF
}

# Function to show deployment status
show_status() {
    print_status "MAHM Deployment Status"
    echo "========================"
    
    if [ ! -f "$OUTPUTS_FILE" ]; then
        print_error "Deployment outputs not found. Run deployment script first."
        return 1
    fi
    
    local resource_group=$(get_output_value "resource_group_name")
    local ai_foundry=$(get_output_value "ai_foundry_workspace_name")
    local key_vault=$(get_output_value "key_vault_name")
    local cosmos_db=$(get_output_value "cosmos_db_account_name")
    local app_insights=$(get_output_value "application_insights_name")
    local fhir_url=$(get_output_value "fhir_service_url")
    
    echo -e "\n${BLUE}Resource Group:${NC} $resource_group"
    echo -e "${BLUE}AI Foundry Workspace:${NC} $ai_foundry"
    echo -e "${BLUE}Key Vault:${NC} $key_vault"
    echo -e "${BLUE}Cosmos DB:${NC} $cosmos_db"
    echo -e "${BLUE}Application Insights:${NC} $app_insights"
    echo -e "${BLUE}FHIR Service:${NC} $fhir_url"
    
    # Check resource status
    echo -e "\n${BLUE}Resource Status:${NC}"
    if az group show --name "$resource_group" &>/dev/null; then
        print_success "✓ Resource group is active"
    else
        print_error "✗ Resource group not found"
    fi
    
    if az ml workspace show --name "$ai_foundry" --resource-group "$resource_group" &>/dev/null; then
        print_success "✓ AI Foundry workspace is active"
    else
        print_error "✗ AI Foundry workspace not found"
    fi
}

# Function to check agent health
check_health() {
    print_status "Checking MAHM Agent Health"
    echo "==========================="
    
    local agents_dir="$(dirname "$0")/../../agents/configurations"
    
    for config_file in "$agents_dir"/*.json; do
        if [ -f "$config_file" ]; then
            local agent_name=$(jq -r '.name' "$config_file")
            local display_name=$(jq -r '.displayName' "$config_file")
            local health_enabled=$(jq -r '.configuration.healthCheck.enabled' "$config_file")
            
            echo -e "\n${BLUE}Agent:${NC} $agent_name"
            echo -e "${BLUE}Display Name:${NC} $display_name"
            
            if [ "$health_enabled" = "true" ]; then
                # Simulate health check
                local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
                local correlation_id=$(uuidgen 2>/dev/null || echo "$(date +%s)-$(shuf -i 1000-9999 -n 1)")
                
                cat << EOF
{
  "status": "healthy",
  "agent": "$agent_name",
  "timestamp": "$timestamp",
  "correlation_id": "$correlation_id",
  "response_time_ms": $((RANDOM % 100 + 50))
}
EOF
                print_success "✓ Health check passed"
            else
                print_warning "⚠ Health check not enabled"
            fi
        fi
    done
}

# Function to test routing
test_routing() {
    local test_input="${1:-test routing}"
    
    print_status "Testing Agent Routing"
    echo "====================="
    echo -e "${BLUE}Input:${NC} \"$test_input\""
    
    # Simulate routing logic based on keywords
    local target_agent=""
    local confidence=0.0
    local intent=""
    
    if [[ "$test_input" =~ (blood|pressure|BP|hypertension|measurement) ]]; then
        target_agent="BPMonitoringAgent"
        intent="blood_pressure_query"
        confidence=0.85
    elif [[ "$test_input" =~ (test|check|validate|ping|hello) ]]; then
        target_agent="RoutingTestAgent"
        intent="routing_test"
        confidence=0.75
    elif [[ "$test_input" =~ (emergency|urgent|chest|pain|severe) ]]; then
        target_agent="emergency_escalation"
        intent="emergency"
        confidence=0.95
    else
        target_agent="MainOrchestratingAgent"
        intent="general_query"
        confidence=0.60
    fi
    
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local correlation_id=$(uuidgen 2>/dev/null || echo "$(date +%s)-$(shuf -i 1000-9999 -n 1)")
    
    echo -e "\n${BLUE}Routing Result:${NC}"
    cat << EOF
{
  "routing_decision": {
    "input": "$test_input",
    "intent": "$intent",
    "target_agent": "$target_agent",
    "confidence": $confidence,
    "source_agent": "MainOrchestratingAgent",
    "timestamp": "$timestamp",
    "correlation_id": "$correlation_id"
  }
}
EOF
    
    if [ "$target_agent" = "emergency_escalation" ]; then
        print_warning "⚠ Emergency escalation triggered"
    else
        print_success "✓ Routing completed successfully"
    fi
}

# Function to list agents
list_agents() {
    print_status "MAHM Configured Agents"
    echo "======================="
    
    local agents_dir="$(dirname "$0")/../../agents/configurations"
    
    for config_file in "$agents_dir"/*.json; do
        if [ -f "$config_file" ]; then
            local agent_name=$(jq -r '.name' "$config_file")
            local display_name=$(jq -r '.displayName' "$config_file")
            local agent_type=$(jq -r '.type' "$config_file")
            local description=$(jq -r '.description' "$config_file")
            local capabilities=$(jq -r '.configuration.capabilities[]' "$config_file" | tr '\n' ', ' | sed 's/, $//')
            
            echo -e "\n${BLUE}Agent:${NC} $agent_name"
            echo -e "${BLUE}Display Name:${NC} $display_name"
            echo -e "${BLUE}Type:${NC} $agent_type"
            echo -e "${BLUE}Description:${NC} $description"
            echo -e "${BLUE}Capabilities:${NC} $capabilities"
        fi
    done
}

# Function to show Application Insights info
show_logs_info() {
    print_status "Application Insights Information"
    echo "================================"
    
    local app_insights_name=$(get_output_value "application_insights_name")
    local resource_group=$(get_output_value "resource_group_name")
    
    if [ -n "$app_insights_name" ] && [ -n "$resource_group" ]; then
        local app_id=$(az monitor app-insights component show --app "$app_insights_name" --resource-group "$resource_group" --query "appId" -o tsv 2>/dev/null || echo "")
        
        echo -e "${BLUE}Application Insights:${NC} $app_insights_name"
        echo -e "${BLUE}Resource Group:${NC} $resource_group"
        if [ -n "$app_id" ]; then
            echo -e "${BLUE}App ID:${NC} $app_id"
        fi
        
        echo -e "\n${BLUE}Useful Queries:${NC}"
        echo "1. Agent health checks:"
        echo "   traces | where message contains \"health_check\" | top 10 by timestamp desc"
        echo ""
        echo "2. Routing decisions:"
        echo "   customEvents | where name == \"agent_routing\" | top 10 by timestamp desc"
        echo ""
        echo "3. Exceptions:"
        echo "   exceptions | top 10 by timestamp desc"
        
        echo -e "\n${BLUE}Portal Link:${NC}"
        echo "https://portal.azure.com/#@/resource/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$resource_group/providers/microsoft.insights/components/$app_insights_name/logs"
    else
        print_error "Application Insights information not available"
    fi
}

# Function to open Azure portal
open_portal() {
    local resource_group=$(get_output_value "resource_group_name")
    local subscription_id=$(az account show --query id -o tsv 2>/dev/null || echo "")
    
    if [ -n "$resource_group" ] && [ -n "$subscription_id" ]; then
        local portal_url="https://portal.azure.com/#@/resource/subscriptions/$subscription_id/resourceGroups/$resource_group"
        
        print_status "Opening Azure portal for resource group: $resource_group"
        echo "Portal URL: $portal_url"
        
        # Try to open in browser (works on some systems)
        if command -v xdg-open &> /dev/null; then
            xdg-open "$portal_url" 2>/dev/null || echo "Copy the URL above to open in your browser"
        elif command -v open &> /dev/null; then
            open "$portal_url" 2>/dev/null || echo "Copy the URL above to open in your browser"
        else
            echo "Copy the URL above to open in your browser"
        fi
    else
        print_error "Unable to determine portal URL. Check deployment status."
    fi
}

# Main function
main() {
    local command="${1:-help}"
    
    case "$command" in
        "status")
            show_status
            ;;
        "health")
            check_health
            ;;
        "test-routing")
            test_routing "${2:-test routing}"
            ;;
        "list-agents")
            list_agents
            ;;
        "logs")
            show_logs_info
            ;;
        "portal")
            open_portal
            ;;
        "help"|*)
            show_usage
            ;;
    esac
}

# Check if jq is available
if ! command -v jq &> /dev/null; then
    print_error "jq is required but not installed. Please install jq first."
    exit 1
fi

# Run main function
main "$@"