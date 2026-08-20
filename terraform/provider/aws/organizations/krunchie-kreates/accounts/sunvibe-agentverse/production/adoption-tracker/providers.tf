terraform {
  required_providers {
    # 6.x is required, not merely preferred: aws_bedrockagentcore_agent_runtime
    # and the Serverless v2 scale-to-zero arguments both landed in 6.x, and
    # discovering that during an apply costs an afternoon.
    aws     = { source = "hashicorp/aws", version = ">= 6.0" }
    archive = { source = "hashicorp/archive", version = ">= 2.4" }
    random  = { source = "hashicorp/random", version = ">= 3.5" }
    local   = { source = "hashicorp/local", version = ">= 2.4" }
  }
}

provider "aws" {
  region = var.region

  assume_role {
    role_arn = "arn:aws:iam::${var.client_account_id}:role/OrganizationAccountAccessRole"
  }

  default_tags {
    tags = {
      Client      = var.client
      Environment = var.environment
      ManagedBy   = "terraform"
      Project     = "sunvibe-agentverse-adoption-tracker"
    }
  }
}
