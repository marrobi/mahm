# Local values for common configurations
locals {
  # Common tags applied to all resources
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    CostCenter  = var.cost_center
    Owner       = var.owner
    ManagedBy   = "terraform"
    Purpose     = "mahm-ai-foundry-demo"
    DataClassification = "demo-data-only"
  }

  # Resource naming convention
  resource_suffix = "${var.environment}-${formatdate("YYYYMMDD", timestamp())}"
}